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
#import "SDLSecurityLoggerMacros.h"


@interface _SDLCertificateManager ()

@property (nonatomic, copy) NSString *certificateURL;

@end


@implementation _SDLCertificateManager

- (instancetype)initWithCertificateServerURL:(NSString *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _certificateURL = url;
    
    return self;
}

+ (NSString *)sdl_buildSecurityDirectory {
    SDLSecurityLogD(@"Creating certificate directory");
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *securityDirectoryName = [NSString stringWithFormat:@"sdl_security_%@", VendorName];
    NSString *securityPath = [documentsPath stringByAppendingPathComponent:securityDirectoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:securityPath]) {
        NSError *directoryCreationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:securityPath withIntermediateDirectories:NO attributes:nil error:&directoryCreationError];
        if (directoryCreationError != nil) {
            SDLSecurityLogE(@"Error creating certificate directory: %@", directoryCreationError);
        }
    }
    
    return securityPath;
}

+ (NSString *)sdl_certificateFilePath {
    NSString *securityPath = [self sdl_buildSecurityDirectory];
    NSString *certificatePath = [securityPath stringByAppendingPathComponent:@"cert.pfx"];
    
    return certificatePath;
}

+ (void)sdl_deleteCertificate {
    SDLSecurityLogD(@"Deleting certificate");
    NSString *certificatePath = [self sdl_certificateFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:certificatePath]) {
        SDLSecurityLogW(@"No certificate to delete");
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
    SDLSecurityLogD(@"Performing network request for a certificate");

    NSArray<NSURLQueryItem *> *queryItems = @[[[NSURLQueryItem alloc] initWithName:@"appID" value:appId]];
    NSURLComponents *queryComponents = [NSURLComponents componentsWithString:self.certificateURL];
    queryComponents.queryItems = queryItems;
    NSURL *url = queryComponents.URL;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data.length == 0) {
            SDLSecurityLogE(@"No data returned");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNoCertificate userInfo:@{NSLocalizedDescriptionKey: @"Network request did not return data"}]);
        }

        NSError *jsonError = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSDictionary *jsonDictionary = jsonArray.firstObject;

        if (jsonError != nil || jsonDictionary == nil) {
            SDLSecurityLogE(@"Error parsing network request data");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNoCertificate userInfo:@{NSLocalizedDescriptionKey: @"Network request did not return a certificate"}]);
        }

        NSData *certificateData = [[NSData alloc] initWithBase64EncodedData:[jsonDictionary objectForKey:@"certificate"] options:0];
        if (certificateData.length == 0) {
            SDLSecurityLogE(@"Certificate is invalid");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:@{NSLocalizedDescriptionKey: @"Certificate is invalid"}]);
        }

        // Store the cert data as a file on disk
        NSError *writeFileError = nil;
        [self.class sdl_deleteCertificate];
        BOOL writeSuccess = [certificateData writeToFile:[[self class] sdl_certificateFilePath] options:0 error:&writeFileError];
        if (!writeSuccess) {
            SDLSecurityLogE(@"Error writing certificate to disk: %@", writeFileError.localizedDescription);
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:@{NSLocalizedDescriptionKey: writeFileError.localizedDescription}]);
        }

        // Certificate downloaded and saved to disk successfully
        SDLSecurityLogD(@"Certificate downloaded successfully");
        return completionHandler(YES, nil);
    }];

    [task resume];
}

@end
