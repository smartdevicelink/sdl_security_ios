//
//  SDLTLSEngine.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/28/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Manager class for encrypting and decrypting data using the OpenSSL library.
@interface SDLTLSEngine : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Constructs a SDLTLSEngine object with the appID of the SDL app
/// @param appId The appID of the SDL app
- (instancetype)initWithAppId:(NSString *)appId NS_DESIGNATED_INITIALIZER;

/// Initializes the DTLS engine using certificate data returned by the certificate manager. If no certificate exists or the certificate is expired, an attempt is made to download a new certificate.
/// @param completionHandler Returns whether or not initialization succeeded. An error is returned if initialization failed
- (void)initializeTLSWithCompletionHandler:(void(^)(BOOL success, NSError *_Nullable error))completionHandler;

/// Initializes the DTLS engine using the provided certificate data.
/// Used for testing
/// @param data The PFX certificate data which should be base64 encoded
/// @param error The error is set if initialization failed
- (BOOL)initializeTLSWithCertificateData:(NSData *)data error:(NSError **)error;

/// Closes the the current DTLS/SSL connection.
- (void)shutdownTLS;

/// Generates handshake data using client data.
/// @param data The client data to be passed to the TLS engine
/// @param error The error is set if the handshake fails
- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError **)error;

/// Decrypts data using the current DTLS session. If decryption fails, `nil` is returned and the `error` parameter should be checked for an error message.
/// @param encryptedData The encrypted data to be decrypted
/// @param error The error is set if decryption fails
- (nullable NSData *)decryptData:(NSData *)encryptedData withError:(NSError **)error;

/// Encrypt data using the current DTLS session. If encyption fails, `nil` is returned and the `error` parameter should be checked for an error message.
/// @param decryptedData The data to encrypt
/// @param error The error is set if encryption fails
- (nullable NSData *)encryptData:(NSData *)decryptedData withError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
