//
//  SDLSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/28/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SDLSecurityErrorDomain;

typedef NS_ENUM(NSUInteger, SDLTLSErrorCode) {
    SDLTLSErrorCodeNone,
    SDLTLSErrorCodeSSL,
    SDLTLSErrorCodeWantRead,
    SDLTLSErrorCodeWantWrite,
    SDLTLSErrorCodeWriteFailed,
    SDLTLSErrorCodeGeneric,
    SDLTLSErrorCodeNotInitialized,
    SDLTLSErrorCodeInitializationFailure,
    SDLTLSErrorCodeNoCertificate,
    SDLTLSErrorCodeCertificateExpired,
    SDLTLSErrorCodeCertificateInvalid
};

NS_ASSUME_NONNULL_BEGIN

@interface SDLSecurityConstants : NSObject

@end

NS_ASSUME_NONNULL_END
