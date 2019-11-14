//
//  SDLPrivateSecurityConstants.m
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLPrivateSecurityConstants.h"

NSString * _Nonnull const CertDevURL = @"http://www.google.com";
NSString * _Nonnull const CertQAURL = @"http://www.google.com";
NSString * _Nonnull const CertProdURL = @"http://www.google.com";
NSString * _Nonnull const VendorName = @"SDL";
NSString * _Nonnull const SDLTLSIssuer = @"SDLTLSIssuer";
const char *SDLTLSCertPassword = "SDLTLSCertPassword";

NS_ASSUME_NONNULL_BEGIN

@implementation SDLPrivateSecurityConstants

+ (NSSet<NSString *> *)availableMakes {
    return [NSSet setWithArray:@[@"SDL"]];
}

@end

NS_ASSUME_NONNULL_END
