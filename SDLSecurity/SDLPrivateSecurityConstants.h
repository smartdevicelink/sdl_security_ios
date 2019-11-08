//
//  SDLPrivateSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CertificateURL;
extern NSString *const VendorName;
extern NSString *const SDLTLSIssuer;
extern const char *SDLTLSCertPassword;

@interface SDLPrivateSecurityConstants : NSObject

+ (NSSet<NSString *> *)availableMakes;

@end
