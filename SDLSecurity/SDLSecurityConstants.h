//
//  SDLSecurityConstants.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/28/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Custom error domain for the security library
extern NSString *const SDLSecurityErrorDomain;

/// An enum for all the errors returned by the security library
typedef NS_ENUM(NSUInteger, SDLTLSErrorCode) {
    /// No error occured
    SDLTLSErrorCodeNone,
    /// A non-recoverable, fatal error in the SSL library occurred
    SDLTLSErrorCodeSSL,
    /// The OpenSSL read operation did not complete
    SDLTLSErrorCodeWantRead,
    /// The OpenSSL write operation did not complete
    SDLTLSErrorCodeWantWrite,
    /// The OpenSSL write operation failed
    SDLTLSErrorCodeWriteFailed,
    /// An unknown error occured with the OpenSSL library
    SDLTLSErrorCodeGeneric,
    /// The DTLS/SSL connection is not in a state where fully protected data can be transferred
    SDLTLSErrorCodeNotInitialized,
    /// The PFX file's keys or certificate parameters are incorrect
    SDLTLSErrorCodeInitializationFailure,
    /// There is no certificate
    SDLTLSErrorCodeNoCertificate,
    /// The certificate is expired
    SDLTLSErrorCodeCertificateExpired,
    /// The certificate data is missing or invalid
    SDLTLSErrorCodeCertificateInvalid
};

NS_ASSUME_NONNULL_BEGIN

@interface SDLSecurityConstants : NSObject

@end

NS_ASSUME_NONNULL_END
