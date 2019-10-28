//
//  SDLSecurityManager.m
//  SDLSecurity
//
//  Created by Joel Fischer on 1/21/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLSecurityManager.h"

#import "SDLCertificateManager.h"
#import "SDLTLSEngine.h"
#import "SDLPrivateSecurityConstants.h"
#import "SDLSecurityConstants.h"

typedef NS_ENUM(NSUInteger, SDLTLSState) {
    SDLTLSStateUninitialized,
    SDLTLSStateInitialized,
    SDLTLSStateConnected
};


NS_ASSUME_NONNULL_BEGIN

@interface SDLSecurityManager () {
    @private
    SDLTLSEngine *_privateSecurity;
}

@property (assign, nonatomic) SDLTLSState state;

@end


@implementation SDLSecurityManager

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _state = SDLTLSStateUninitialized;
    
    return self;
}

- (void)initializeWithAppId:(NSString *)appId completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    _appId = appId;
    
    // If it's already initialized, return
    if (self.state != SDLTLSStateUninitialized) {
        completionHandler(nil);
        return;
    }
    
    // Set up the TLS engine
    _privateSecurity = [[SDLTLSEngine alloc] initWithAppId:appId];
    [_privateSecurity initializeTLSWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            self.state = SDLTLSStateInitialized;
        }
        
        completionHandler(error);
    }];
}

- (void)stop {
    [_privateSecurity shutdownTLS];
    self.state = SDLTLSStateUninitialized;
}

- (nullable NSData *)runHandshakeWithClientData:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error {
    NSData *serverData = [_privateSecurity runHandshakeWithClientData:data error:error];
    
    if (serverData != nil) {
        self.state = SDLTLSStateConnected;
    }
    
    return serverData;
}

- (nullable NSData *)encryptData:(NSData *)data withError:(NSError * _Nullable __autoreleasing *)error {
    return [_privateSecurity encryptData:data withError:error];
}

- (nullable NSData *)decryptData:(NSData *)data withError:(NSError * _Nullable __autoreleasing *)error {
    return [_privateSecurity decryptData:data withError:error];
}

+ (NSSet<NSString *> *)availableMakes {
    return availableMakes;
}

@end

NS_ASSUME_NONNULL_END
