//
//  SDLTLSEngine.m
//  SDLSecurity
//
//  Created by Joel Fischer on 1/28/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLTLSEngine.h"

#import <openssl/bio.h>
#import <openssl/ssl.h>
#import <openssl/err.h>
#import <openssl/conf.h>
#import <openssl/pkcs12.h>

#import "SDLCertificateManager.h"
#import "SDLPrivateSecurityConstants.h"
#import "SDLSecurityConstants.h"
#import "SDLSecurityLoggerMacros.h"


NS_ASSUME_NONNULL_BEGIN

/// An enum describing the state of the DTLS/SSL connection.
typedef NS_ENUM(NSUInteger, SDLTLSEngineState) {
    /// The connection is closed
    SDLTLSEngineStateDisconnected,
    /// The connection is established
    SDLTLSEngineStateInitialized,
};

static const int SDLTLSReadBufferSize = 4096;

@interface SDLTLSEngine () {
    /// Configuration for establishing the DTLS/SSL enabled connection
    SSL_CTX *sslContext;
    /// The DTLS/SSL connection
    SSL *sslConnection;
    /// Read and write memory BIOs
    BIO *readBIO;
    BIO *writeBIO;
}

/// The current state of the DTLS/SSL connection.
@property (assign, nonatomic) SDLTLSEngineState state;
/// Manager for downloading and caching a certificate.
@property (strong, nonatomic) SDLCertificateManager *certificateManager;
/// The appID of the SDL app
@property (copy, nonatomic) NSString *appId;

@end

/*
This diagram shows how data is encrypted and decrypted using the OpenSSL library.
+------------------------------------------------------------------------------------------------------+
encrypted bytes ---> BIO_write(readBIO) -------> |*****| -> SSL_read(sslConnection) -> unencrypted bytes
                                                 |*SSL*|
unencrypted bytes -> SSL_write(sslConnection) -> |*****| -> BIO_read(writeBIO) ------> encrypted bytes
+------------------------------------------------------------------------------------------------------+
*/
@implementation SDLTLSEngine

#pragma mark - Lifecycle

- (instancetype)init {
    return nil;
}

- (instancetype)initWithAppId:(NSString *)appId {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _state = SDLTLSEngineStateDisconnected;
    _appId = appId;
    _certificateManager = [[SDLCertificateManager alloc] initWithCertificateServerURL:CertificateURL];

    [self.class sdlsec_OpenSSLInitialization];

    return self;
}

// http://stackoverflow.com/questions/6371775/how-to-load-a-pkcs12-file-in-openssl-programmatically
- (void)initializeTLSWithCompletionHandler:(void (^)(BOOL success, NSError * _Nullable))completionHandler {
    SDLSecurityLogD(@"Initializing TLS");
    NSData *certData = self.certificateManager.certificateData;
    
    if (certData.length == 0) {
        SDLSecurityLogW(@"TLS certificate doesn't exist, retrieving new certificate");
        [self.certificateManager retrieveNewCertificateWithAppId:self.appId completionHandler:^(BOOL success, NSError * _Nullable networkError) {
            if (!success) {
                SDLSecurityLogE(@"Failed to download certificate with error: %@", networkError);
                return completionHandler(NO, networkError);
            }
            
            // Certificate has been downloaded. Recurse back into this method to try again with the new certificate data.
            return [self initializeTLSWithCompletionHandler:completionHandler];
        }];
    } else {
        SDLSecurityLogD(@"TLS certificate found");
        NSError *tlsError = nil;
        BOOL success = [self initializeTLSWithCertificateData:certData error:&tlsError];

        if (!success) {
            if (tlsError.code == SDLTLSErrorCodeCertificateExpired) {
                SDLSecurityLogW(@"TLS certificate is expired, retrieving new certificate");
                [self.certificateManager retrieveNewCertificateWithAppId:self.appId completionHandler:^(BOOL success, NSError * _Nullable networkError) {
                    if (!success) {
                        SDLSecurityLogE(@"Failed to download certificate with error: %@", networkError);
                        return completionHandler(NO, networkError);
                    }

                    // Certificate has been downloaded. Recurse back into this method to try again with the new certificate data.
                    return [self initializeTLSWithCompletionHandler:completionHandler];
                }];
            } else {
                SDLSecurityLogE(@"TLS certificate initialization failed with unknown error: %@", tlsError);
                return completionHandler(NO, tlsError);
            }
        } else {
            SDLSecurityLogD(@"TLS certificate initialization succeeded");
            return completionHandler(YES, nil);
        }
    }
}

- (BOOL)initializeTLSWithCertificateData:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error {
    SDLSecurityLogD(@"Initializing and verifying TLS certificate");

    PKCS12 *p12 = NULL;
    EVP_PKEY *pkey = NULL;
    X509 *certX509 = NULL;
    RSA *rsa = NULL;
    BIO *pbio = NULL;
    BOOL success = NO;
    
    void *p12Buffer = (void *)data.bytes;

    [self.class sdlsec_OpenSSLInitialization];

    sslContext = SSL_CTX_new(DTLS_server_method());
    SSL_CTX_set_verify(sslContext, SSL_VERIFY_NONE, NULL);
    
    long options = SSL_OP_NO_SSLv2 | SSL_OP_NO_COMPRESSION | SSL_OP_SINGLE_DH_USE | SSL_OP_SINGLE_ECDH_USE;
    SSL_CTX_set_options(sslContext, options);
    pbio = BIO_new_mem_buf(p12Buffer, (int)data.length);
    p12 = d2i_PKCS12_bio(pbio, NULL);
    if (p12 == NULL) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"TLS certificate failed to load"}];
        return NO;
    }

    success = PKCS12_parse(p12, SDLTLSCertPassword, &pkey, &certX509, NULL);
    if (certX509 == NULL || pkey == NULL) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"TLS password does not match"}];
        return NO;
    }
    
    // https://zakird.com/2013/10/13/certificate-parsing-with-openssl/
    // Check that the certificate has not already expired
    NSDate *certExpiryDate = sdlsec_certificateGetExpiryDate(certX509);
    if ([[NSDate date] compare:certExpiryDate] != NSOrderedAscending) {
        sdlsec_cleanUpInitialization(certX509, NULL, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateExpired userInfo:@{NSLocalizedDescriptionKey: @"Certificate expired"}];
        return NO;
    }
    
    // Check that the certificate's issuer is correct
    NSString *certIssuer = [NSString stringWithUTF8String:X509_NAME_oneline(X509_get_issuer_name(certX509), NULL, 0)];
    if (![certIssuer isEqualToString:SDLTLSIssuer]) {
        sdlsec_cleanUpInitialization(certX509, NULL, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:@{NSLocalizedDescriptionKey: @"Certificate issuer does not match required issuer"}];
        return NO;
    }
    
    rsa = EVP_PKEY_get1_RSA(pkey);
    if (rsa == NULL) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"Retrieving RSA token failed"}];
        return NO;
    }
    
    // Set up our SSL Context with the certificate and key
    success = SSL_CTX_use_certificate(sslContext, certX509);
    if (!success) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"Setting up SSL context failed"}];
        return NO;
    }
    
    success = SSL_CTX_use_RSAPrivateKey(sslContext, rsa);
    if (!success) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"Setting up SSL context failed with the private key"}];
        return NO;
    }
    
    success = SSL_CTX_check_private_key(sslContext);
    if (!success) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"SSL Private key check failed"}];
        return NO;
    }
    
    success = SSL_CTX_set_cipher_list(sslContext, "ALL");
    if (!success) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"Setting up SSL context cipher list failed"}];
        return NO;
    }
    
    sslConnection = SSL_new(sslContext);
    if (sslConnection == NULL) {
        sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeInitializationFailure userInfo:@{NSLocalizedDescriptionKey: @"Creating SSL connection object failed"}];
        return NO;
    }
    
    readBIO = BIO_new(BIO_s_mem());
    writeBIO = BIO_new(BIO_s_mem());
    BIO_set_mem_eof_return(readBIO, -1);
    SSL_set_bio(sslConnection, readBIO, writeBIO);
    SSL_set_accept_state(sslConnection);
    sdlsec_cleanUpInitialization(certX509, rsa, p12, pbio, pkey);
    
    self.state = SDLTLSEngineStateInitialized;
    return YES;
}

/// Destroys the OpenSSL structs created when extracting the PFX file's certificate and keys.
/// @param cert The certificate data
/// @param rsa The public key
/// @param p12 The PFX file
/// @param pbio Memory BIO for the PFX file
/// @param pkey The private key
void sdlsec_cleanUpInitialization(X509 *_Nullable cert, RSA *_Nullable rsa, PKCS12 *_Nullable p12, BIO *_Nullable pbio, EVP_PKEY *_Nullable pkey) {
    if (cert != NULL) {
        X509_free(cert);
    }
    if (rsa != NULL) {
        RSA_free(rsa);
    }
    if (p12 != NULL) {
        PKCS12_free(p12);
    }
    if (pbio != NULL) {
        BIO_free(pbio);
    }
    if (pkey != NULL) {
        EVP_PKEY_free(pkey);
    }
}

/// Initilizes OpenSSL's libssl library by loading the error codes and algorithms.
+ (void)sdlsec_OpenSSLInitialization {
    SSL_load_error_strings();
    ERR_load_BIO_strings();
    OpenSSL_add_all_algorithms();
    SSL_library_init();
}

- (void)shutdownTLS {
    SDLSecurityLogD(@"Shutting down TLS engine");
    if (self.state != SDLTLSEngineStateInitialized) {
        return;
    }

    if (sslConnection != NULL) {
        [self sdlsec_shutdown];
        SSL_free(sslConnection);
    }

    if (sslContext != NULL) {
        SSL_CTX_free(sslContext);
    }

    CONF_modules_unload(1);
    ERR_free_strings();

    EVP_cleanup();

    sk_SSL_COMP_free(SSL_COMP_get_compression_methods());
    CRYPTO_cleanup_all_ex_data();
}

/// Closes the open DTLS/SSL session. A bidirectional shutdown handshake must be performed, which means the shutdown attempt should be tried again if the return value of the shutdown is zero.
- (void)sdlsec_shutdown {
    int retryCount = 0;
    for (int i = 0; i < 4; i++) {
        retryCount = SSL_shutdown(sslConnection);
        if (retryCount > 0) {
            // The retryCount will be 1 when a bidirectional shutdown has completed successfully
            break;
        }
    }
}

#pragma mark - Certificate Validity

/// Gets the expiration date of the certificate
/// @param certificateX509 The certificate data
/// http://stackoverflow.com/questions/8850524/seccertificateref-how-to-get-the-certificate-information
static NSDate *sdlsec_certificateGetExpiryDate(X509 *certificateX509) {
    SDLSecurityLogD(@"Verifying certificate expiration date");
    NSDate *expiryDate = nil;
    
    if (certificateX509 != NULL) {
        ASN1_TIME *certificateExpiryASN1 = X509_get_notAfter(certificateX509);
        if (certificateExpiryASN1 != NULL) {
            ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            if (certificateExpiryASN1Generalized != NULL) {
                const unsigned char *certificateExpiryData = ASN1_STRING_get0_data(certificateExpiryASN1Generalized);
                
                // ASN1 generalized times look like this: "20131114230046Z"
                //                                format:  YYYYMMDDHHMMSS
                //                               indices:  01234567890123
                //                                                   1111
                // There are other formats (e.g. specifying partial seconds or
                // time zones) but this is good enough for our purposes since
                // we only use the date and not the time.
                //
                // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)
                
                NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
                NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
                
                expiryDateComponents.year = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
                expiryDateComponents.month = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
                expiryDateComponents.day = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
                expiryDateComponents.hour = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
                expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
                expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                expiryDate = [calendar dateFromComponents:expiryDateComponents];
            }
        }
    }

    return expiryDate;
}

#pragma mark - Handshake

- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error {
    if ([self sdlsec_WriteEncryptedDataToSSLServer:data withError:error] <= 0) {
        return nil;
    }

    [self sdlsec_TLSHandshake];

    NSData *dataToSend = [self sdlsec_ReadEncryptedDataFromSSLServerWithError:error];

    [self sdlsec_TLSHandshake];

    return dataToSend;
}

/// Checks whether the DTLS/SSL connection is in a state where fully protected data can be transferred. If not, a handshake is attempted and the connection state is checked again before returning.
- (BOOL)sdlsec_TLSHandshake {
    if (sslConnection == NULL) {
        return NO;
    }

    if (!SSL_is_init_finished(sslConnection)) {
        // Since the underlying BIO is blocking, this will only return once the handshake has been finished or an error occurred
        SSL_do_handshake(sslConnection);
    }

    return SSL_is_init_finished(sslConnection);
}


#pragma mark - Encrypt / Decrypt Data

- (nullable NSData *)encryptData:(NSData *)decryptedData withError:(NSError * _Nullable __autoreleasing *)error {
    if (![self sdlsec_TLSHandshake]) {
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNotInitialized userInfo:@{NSLocalizedDescriptionKey: @"Cannot encrypt data because TLS is not initialized"}];
        return nil;
    }
    
    [self sdlsec_WriteUnencryptedDataToSSLServer:decryptedData withError:error];
    if (*error != nil) {
        return nil;
    }
    
    NSData *encryptedData = [self sdlsec_ReadEncryptedDataFromSSLServerWithError:error];
    if (*error != nil) {
        return nil;
    }

    return encryptedData;
}

- (nullable NSData *)decryptData:(NSData *)encryptedData withError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (![self sdlsec_TLSHandshake]) {
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNotInitialized userInfo:@{NSLocalizedDescriptionKey: @"Cannot decrypt data because TLS is not initialized"}];
        return nil;
    }
    
    [self sdlsec_WriteEncryptedDataToSSLServer:encryptedData withError:error];
    if (*error != nil) {
        return nil;
    }
    
    NSData *data = [self sdlsec_ReadUnencryptedDataFromSSLServerWithError:error];
    if (*error != nil) {
        return nil;
    }
    
    return data;
}


#pragma mark OpenSSL Encryption / Decryption

/// Writes the unencrypted data to the OpenSSL server so it can be encrypted and returns the number of bytes successfully written.
/// @param data The unencrypted data
/// @param error The error will be set if the data can not be written successfully
- (int)sdlsec_WriteUnencryptedDataToSSLServer:(NSData *)data withError:(NSError * __autoreleasing*)error {
    int length = (int)data.length;
    void *buffer = (void *)data.bytes;
    int retVal = SSL_write(sslConnection, buffer, length);

    SDLTLSErrorCode errorCode = [self.class sdlsec_errorCodeFromSSL:sslConnection value:retVal length:length isWrite:NO];
    if ((errorCode != SDLTLSErrorCodeNone) && (*error != nil)) {
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: @"Cannot write data to SSL server"}];
    }

    return retVal;
}

/// Retrieves the unencrypted data from the OpenSSL server.
/// @param error The error will be set if the data can not be read successfully
- (nullable NSData *)sdlsec_ReadUnencryptedDataFromSSLServerWithError:(NSError * __autoreleasing*)error {
    NSMutableData *unencryptedData = [NSMutableData data];
    int length = SDLTLSReadBufferSize;
    void *buffer = malloc(SDLTLSReadBufferSize);
    int bufferLength = 0;

    while ((bufferLength = SSL_read(sslConnection, buffer, length)) >= 0) {
        [unencryptedData appendBytes:buffer length:bufferLength];

        SDLTLSErrorCode errorCode = [self.class sdlsec_errorCodeFromSSL:sslConnection value:bufferLength length:length isWrite:NO];
        if ((errorCode != SDLTLSErrorCodeNone) && (*error != nil)) {
            *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: @"Cannot SSL read data from server"}];
        }
    }

    return unencryptedData;
}

/// Writes encrypted data to the OpenSSL server so it can be decrypted and returns the number of bytes successfully written.
/// @param data Encrypted data
/// @param error The error will be set if the data can not be written successfully
- (int)sdlsec_WriteEncryptedDataToSSLServer:(NSData *)data withError:(NSError * __autoreleasing*)error {
    int length = (int)data.length;
    void *buffer = (void *)data.bytes;
    int retVal = BIO_write(readBIO, buffer, length);

    SDLTLSErrorCode errorCode = [self.class sdlsec_errorCodeFromSSL:sslConnection value:retVal length:length isWrite:NO];
    if ((errorCode != SDLTLSErrorCodeNone) && (*error != nil)) {
        *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: @"Cannot BIO write data to server"}];
    }

    return retVal;
}

/// Retrieves the encrypted data from the OpenSSL server.
/// @param error The error will be set if the data can not be retrieved successfully
- (nullable NSData *)sdlsec_ReadEncryptedDataFromSSLServerWithError:(NSError * __autoreleasing*)error {
    NSMutableData *returnData = [NSMutableData data];
    int length = SDLTLSReadBufferSize;
    void *buffer = malloc(SDLTLSReadBufferSize);
    int bufferLength = 0;

    while ((bufferLength = BIO_read(writeBIO, buffer, length)) >= 0) {
        [returnData appendBytes:buffer length:bufferLength];

        SDLTLSErrorCode errorCode = [self.class sdlsec_errorCodeFromSSL:sslConnection value:bufferLength length:length isWrite:NO];
        if ((errorCode != SDLTLSErrorCodeNone) && (*error != nil)) {
            *error = [NSError errorWithDomain:SDLSecurityErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: @"Cannot BIO read data from server"}];
        }
    }

    return returnData;
}


#pragma mark - Errors

/// Examines the result code returned when attempting to read or write data from the server and returns a human readable version of the result code. If an error occured, an error is returned; if successful no error is returned.
/// @param ssl The DTLS/SSL connection
/// @param value The value returned by the read or write action
/// @param length The length of the data read or written
/// @param isWrite True if a write action is being attempted; false if not
+ (SDLTLSErrorCode)sdlsec_errorCodeFromSSL:(SSL *)ssl value:(int)value length:(int)length isWrite:(BOOL)isWrite {
    // Get the result code for the preceding call to ssl
    int error = SSL_get_error(ssl, value);

    switch(error) {
        case SSL_ERROR_NONE:
            if((length != value) && isWrite) {
                return SDLTLSErrorCodeWriteFailed;
            } else {
                return SDLTLSErrorCodeNone;
            }
        case SSL_ERROR_SSL: {
            return SDLTLSErrorCodeSSL;
        }
        case SSL_ERROR_WANT_READ: {
            return SDLTLSErrorCodeWantRead;
        }
        case SSL_ERROR_WANT_WRITE: {
            return SDLTLSErrorCodeWantWrite;
        }
        default: {
            return SDLTLSErrorCodeGeneric;
        }
    }
}

@end

NS_ASSUME_NONNULL_END
