//
//  SDLCertificateManager.h
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A completion handler called when the certificate retrieval has finished.
/// @param success True if the certficate was downloaded and cached successfully; false if an error occured
/// @param error The error that occured during the certificate downloaded, if any occurred
typedef void (^SDLCertificateRetrievedHandler)(BOOL success, NSError *__nullable error);

/// Manager class for downloading and caching a PFX file (A PFX file contains the certificate, public key, and private key).
@interface SDLCertificateManager : NSObject

/// The cached PFX file data.
@property (nonatomic, copy, readonly, nullable) NSData *certificateData;

- (instancetype)init NS_UNAVAILABLE;

/// Initializes the certificate manager with the URL where all the PFX files are hosted.
/// @param url The URL where the PFX files are being hosted.
- (instancetype)initWithCertificateServerURL:(NSString *)url;

/// Retrieves the unique PFX file associated with the appId. To retrieve the PFX file, the passed appId is added to the url as a query string for the key `appId`. The downloaded PFX data is then cached on disk.
/// @param appId The appID of the SDL app
/// @param completionHandler Handler called when certificate retrieval has finished
- (void)retrieveNewCertificateWithAppId:(NSString *)appId completionHandler:(SDLCertificateRetrievedHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
