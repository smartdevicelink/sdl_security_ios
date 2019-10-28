//
//  SDLPrivateSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSSet<NSString *> *availableMakes;
extern NSString *const CertDevURL;
extern NSString *const CertQAURL;
extern NSString *const CertProdURL;
extern NSString *const VendorName;
extern NSString *const SDLTLSIssuer;
extern const char *SDLTLSCertPassword;

@interface SDLPrivateSecurityConstants : NSObject

@end
