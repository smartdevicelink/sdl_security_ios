//
//  SDLPrivateSecurityConstants.m
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLPrivateSecurityConstants.h"

NSSet<NSString *> *availableMakes;
NSString *const CertDevURL = @"http://www.google.com";
NSString *const CertQAURL = @"http://www.google.com";
NSString *const CertProdURL = @"http://www.google.com";
NSString *const VendorName = @"SDL";
NSString *const SDLTLSIssuer = @"SDLTLSIssuer";
const char *SDLTLSCertPassword = "SDLTLSCertPassword";

@implementation SDLPrivateSecurityConstants

+ (NSSet<NSString *> *)availableMakes {
    return [NSSet setWithArray:@[@"SDL"]];
}

@end
