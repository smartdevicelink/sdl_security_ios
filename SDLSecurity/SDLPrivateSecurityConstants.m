//
//  SDLPrivateSecurityConstants.m
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLPrivateSecurityConstants.h"

/// Sets the certificate url based on whether the build configuration is RELEASE or DEBUG
#if DEBUG
/// Certificate URL for debugging
NSString * _Nonnull const CertDevURL = @"https://www.debugURL.com";
#else
/// Certificate URL for release
NSString * _Nonnull const CertDevURL = @"https://www.productionURL.com";
#endif

const char *SDLTLSCertPassword = "SDLTLSCertPassword";

NS_ASSUME_NONNULL_BEGIN

@implementation SDLPrivateSecurityConstants

+ (NSSet<NSString *> *)availableMakes {
    return [NSSet setWithArray:@[@"SDL"]];
}

@end

NS_ASSUME_NONNULL_END
