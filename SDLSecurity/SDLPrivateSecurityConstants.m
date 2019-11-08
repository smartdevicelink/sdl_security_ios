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
NSString *const CertificateURL = @"https://www.debugURL.com";
#else
/// Certificate URL for release
NSString *const CertificateURL = @"https://www.productionURL.com";
#endif

NSString *const VendorName = @"SDL";
NSString *const SDLTLSIssuer = @"SDLTLSIssuer";
const char *SDLTLSCertPassword = "SDLTLSCertPassword";

@implementation SDLPrivateSecurityConstants

+ (NSSet<NSString *> *)availableMakes {
    return [NSSet setWithArray:@[@"SDL"]];
}

@end
