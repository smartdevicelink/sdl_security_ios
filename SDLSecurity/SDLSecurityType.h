//
//  SDLSecurityType.h
//  SDLSecurity
//
//  Created by Joel Fischer on 2/3/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDLSecurityType <NSObject>

- (void)initializeWithAppId:(NSString *)appId completionHandler:(void(^)(NSError * _Nullable error))completionHandler;
- (void)stop;

- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError **)error;

- (nullable NSData *)encryptData:(NSData *)data withError:(NSError **)error;
- (nullable NSData *)decryptData:(NSData *)data withError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
