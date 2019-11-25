//
//  SDLPrivateSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 3/1/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

/// The URL from which to download the PFX file data.
extern NSString * _Nonnull const CertificateURL;

/// The issuer of the PFX file.
extern NSString * _Nonnull const SDLTLSIssuer;

/// The password used to generate the PFX file.
extern const char * _Nonnull SDLTLSCertPassword;

/// The name of the custom directory folder where the downloaded PFX file will be stored.
extern NSString * _Nonnull const VendorName;

NS_ASSUME_NONNULL_BEGIN

/// Private constants used by the security manager.
@interface SDLPrivateSecurityConstants : NSObject

/// The vehicle types this security library supports.
+ (NSSet<NSString *> *)availableMakes;

@end

NS_ASSUME_NONNULL_END
