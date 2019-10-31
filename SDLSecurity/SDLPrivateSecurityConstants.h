//
//  SDLPrivateSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

/// The URL from which to download the PFX certificate file data
extern NSString *const CertDevURL;
extern NSString *const CertQAURL;
extern NSString *const CertProdURL;

/// The issuer name of the PFX certificate file
extern NSString *const SDLTLSIssuer;

/// The password used to generate the PFX certificate file
extern const char *SDLTLSCertPassword;

/// The name of the custom directory folder where the downloaded certificate will be stored
extern NSString *const VendorName;

/// Private constants used by the security manager.
@interface SDLPrivateSecurityConstants : NSObject

/// The vehicle types this security library supports.
+ (NSSet<NSString *> *)availableMakes;

@end
