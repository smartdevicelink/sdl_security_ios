//
//  _SDLCertificateManager.m
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "_SDLCertificateManager.h"

#import "SDLPrivateSecurityConstants.h"
#import "SDLSecurityConstants.h"


@interface _SDLCertificateManager ()

@property (nonatomic, copy) NSURL *certificateURL;

@end


@implementation _SDLCertificateManager

- (instancetype)initWithCertificateServerURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _certificateURL = url;
    
    return self;
}

+ (NSString *)sdl_buildSecurityDirectory {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *securityDirectoryName = [NSString stringWithFormat:@"sdl_security_%@", VendorName];
    NSString *securityPath = [documentsPath stringByAppendingPathComponent:securityDirectoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:securityPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:securityPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return securityPath;
}

+ (NSString *)sdl_certificateFilePath {
    NSString *securityPath = [self sdl_buildSecurityDirectory];
    NSString *certificatePath = [securityPath stringByAppendingPathComponent:@"cert.pfx"];
    
    return certificatePath;
}

+ (void)sdl_deleteCertificate {
    NSString *certificatePath = [self sdl_certificateFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:certificatePath]) {
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:certificatePath error:nil];
}

- (nullable NSData *)certificateData {
    // Get the certificate's file path
    NSString *certPath = [[self class] sdl_certificateFilePath];
    if (![[NSFileManager defaultManager] isReadableFileAtPath:certPath]) {
        return nil;
    }
    
    // TODO: Decrypt?
    
    // TODO: Return data
    return [NSData dataWithContentsOfFile:certPath];
}

- (void)retrieveNewCertificateWithAppId:(NSString *)appId completionHandler:(SDLCertificateRetrievedHandler)completionHandler {
    // Create the URL request with the required parameters
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:self.certificateURL] mutableCopy];
    if (request == nil) {
        NSLog(@"Error creating security request from URL");
        completionHandler(NO, nil); // TODO: Error
        return;
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    
    // Attempt to serialize the app id dictionary into json data
    NSError *jsonEncodeError = nil;
    NSDictionary *appIdJSON = @{@"appId": appId};
    NSData *appIdData = [NSJSONSerialization dataWithJSONObject:appIdJSON options:0 error:&jsonEncodeError];
    if (appIdData == nil) {
        NSLog(@"Error creating security request JSON");
        completionHandler(NO, jsonEncodeError);
        return;
    }

    [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:appIdData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // If the certificate server didn't send us any data back
        if (data == nil) {
            NSLog(@"Security server responded with an error. Response: %@, Error: %@", response, error);
            completionHandler(NO, error);
            return;
        }

        // Try to decode the server data
        NSError *jsonDecodeError = nil;
        NSDictionary *jsonDecodedDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
        if ((jsonDecodedDict == nil) || (jsonDecodedDict[@"Certificate"] == nil)) {
            completionHandler(NO, jsonDecodeError);
            return;
        }

        // The cert is base 64 encoded. Decode it
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSData *base64Decoded = [[NSData alloc] initWithBase64Encoding:jsonDecodedDict[@"Certificate"]];
#pragma clang diagnostic pop
        if (base64Decoded == nil) {
            completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:nil]);
        }

        // TODO: Encrypt?

        // TODO: Weakself
        // We have the cert data, store it as a file in the correct path
        NSError *writeFileError = nil;
        [[self class] sdl_deleteCertificate];
        BOOL writeSuccess = [base64Decoded writeToFile:[[self class] sdl_certificateFilePath] options:0 error:&writeFileError];
        if (!writeSuccess) {
            completionHandler(NO, error);
            return;
        }

        // Everything succeeded, the new cert exists at the file path
        completionHandler(YES, nil);
    }];
}

@end
