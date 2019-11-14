//
//  SDLSecurityType.h
//  SDLSecurity
//
//  Created by Joel Fischer on 2/3/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol for setting up the OpenSSL cryptographic library for encrypting and decrypting data.
@protocol SDLSecurityType <NSObject>

/// The appID of the SDL app
@property (copy, nonatomic) NSString* appId;

/// Initializes the security manager by downloading a certificate associated with the appID and setting up the OpenSSL I/O channels.
/// @param appId The appID of the SDL app.
/// @param completionHandler Called when initialization completes. If successful, `nil` will be returned; if not successful, an error will be returned.
- (void)initializeWithAppId:(NSString *)appId completionHandler:(void(^)(NSError * _Nullable error))completionHandler;

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
