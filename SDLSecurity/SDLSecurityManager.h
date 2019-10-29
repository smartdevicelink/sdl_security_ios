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

@interface SDLSecurityManager : NSObject <SDLSecurityType>

/// The appID of the SDL app
@property (nonatomic, copy) NSString *appId;

/// Initializes the security manager by downloading and caching a certificate, checking the certificate parameters, and setting up the OpenSSL I/O channels. If a certificate is already cached, it will be used (skipping the download step) unless expired. The appId is used to download the unique certificate for the SDL app.
///
/// @param appId The appID of the SDL app.
/// @param completionHandler Called when initialization completes. If successful, `nil` will be returned; if not successful, an error will be returned.
- (void)initializeWithAppId:(NSString *)appId completionHandler:(void (^)(NSError * _Nullable))completionHandler;

/// Closes the OpenSSL I/O channels.
- (void)stop;

/// Gets the data from Core.
/// @param data <#data description#>
/// @param error <#error description#>
- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError **)error;

- (nullable NSData *)encryptData:(NSData *)data withError:(NSError **)error;
- (nullable NSData *)decryptData:(NSData *)data withError:(NSError **)error;

+ (NSSet<NSString *> *)availableMakes;

@end

NS_ASSUME_NONNULL_END
