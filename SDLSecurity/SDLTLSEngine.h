//
//  SDLSecurityPrivate.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/28/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDLTLSEngine : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAppId:(NSString *)appId NS_DESIGNATED_INITIALIZER;

/**
 *  Use the built in certificate manager to attempt to initialize the TLS engine. This method will try to get stored cert data from the cert manager and if that fails, try to download a new certificate and re-initialize.
 *
 *  @param completionHandler A completion handler that says whether or not initialization succeeded, and if it did not, what error was returned.
 */
- (void)initializeTLSWithCompletionHandler:(void(^)(BOOL success, NSError *_Nullable error))completionHandler;

/**
 *  Mainly for testing, this method will not use the baked in certificate manager to try and get its data.
 *
 *  @param data  The certificate data to use to initialize the TLS engine
 *  @param error An error if initialization failed
 *
 *  @return Whether or not intialization succeeded
 */
- (BOOL)initializeTLSWithCertificateData:(NSData *)data error:(NSError **)error;

/**
 *  End the current TLS instance
 */
- (void)shutdownTLS;

/**
 *  Attempt to generate handshake data as a server using some client data.
 *
 *  @param data  The client data to be passed to the TLS engine
 *  @param error An out-parameter error if something goes wrong
 *
 *  @return Data to send to the client or nil if something went wrong
 */
- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError **)error;

/**
 *  Attempt to decrypt some data using the current TLS session
 *
 *  @param encryptedData The encrypted data to decrypt
 *  @param error         An out-parameter error if something goes wrong
 *
 *  @return The decrypted data or nil if the decryption failed
 */
- (nullable NSData *)decryptData:(NSData *)encryptedData withError:(NSError **)error;
/**
 *  Attempt to decrypt some data using the current TLS session
 *
 *  @param decryptedData The unencrypted data to encrypt
 *  @param error         An out-parameter error if something goes wrong
 *
 *  @return The encrypted data or nil if the encryption failed
 */
- (nullable NSData *)encryptData:(NSData *)decryptedData withError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
