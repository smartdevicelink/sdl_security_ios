//
//  _SDLCertificateManager.h
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SDLCertificateRetrievedHandler)(BOOL success, NSError *__nullable error);


@interface _SDLCertificateManager : NSObject

- (instancetype)initWithCertificateServerURL:(NSURL *)url;

@property (nonatomic, copy, readonly, nullable) NSData *certificateData;

- (void)retrieveNewCertificateWithAppId:(NSString *)appId completionHandler:(SDLCertificateRetrievedHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
