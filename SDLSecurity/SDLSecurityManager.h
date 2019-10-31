//
//  SDLSecurityManager.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/21/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDLSecurityType.h"

NS_ASSUME_NONNULL_BEGIN

/// This class handles encrypting and decrypting the data transmitted between an SDL iOS application and SDL Core. On setup, a certificate associated with the SDL app's unique app id is downloaded from a URL. Then the OpenSSL cryptographic library is used to encrypt and decrypt data using the DTLS protocol.
@interface SDLSecurityManager : NSObject <SDLSecurityType>

/// The appID of the SDL app
@property (nonatomic, copy) NSString *appId;

/// Initializes the security manager by downloading and caching a certificate, checking the certificate parameters, and setting up the OpenSSL I/O channels. If a certificate is already cached, it will be used unless expired. The appId is used to download the unique certificate for the SDL app.
/// @param appId The appID of the SDL app.
/// @param completionHandler Called when initialization completes. If successful, `nil` will be returned; if not successful, an error will be returned.
- (void)initializeWithAppId:(NSString *)appId completionHandler:(void (^)(NSError * _Nullable))completionHandler;

/// Stops the security manager by closing the OpenSSL I/O channels.
- (void)stop;

/// Runs the SSL/DTLS handshake needed to start a secure connection.
/// @param data The data to send to Core
/// @param error The error is set if the handshake fails
- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError **)error;

/// Encrypts data using SSL/DTLS.
/// @param data The data to encrypt
/// @param error The error is set if encryption fails
- (nullable NSData *)encryptData:(NSData *)data withError:(NSError **)error;

/// Decrypts data using SSL/DTLS.
/// @param data The data to decrypt
/// @param error The error is set if decryption fails
- (nullable NSData *)decryptData:(NSData *)data withError:(NSError **)error;

/// The vehicle types this security library supports.
+ (NSSet<NSString *> *)availableMakes;

@end

NS_ASSUME_NONNULL_END
