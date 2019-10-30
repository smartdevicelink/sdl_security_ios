//
//  SDLCertificateManager.h
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SDLCertificateRetrievedHandler)(BOOL success, NSError *__nullable error);


@interface SDLCertificateManager : NSObject

@property (nonatomic, copy, readonly, nullable) NSData *certificateData;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCertificateServerURL:(NSString *)url;
- (void)retrieveNewCertificateWithAppId:(NSString *)appId completionHandler:(SDLCertificateRetrievedHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
