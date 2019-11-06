//
//  SDLCertificateManager.m
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import "SDLCertificateManager.h"

#import "SDLPrivateSecurityConstants.h"
#import "SDLSecurityConstants.h"
#import "SDLSecurityLoggerMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDLCertificateManager ()

/// The URL where the PFX files are being hosted.
@property (nonatomic, copy) NSString *certificateURL;

@end


@implementation SDLCertificateManager

- (instancetype)initWithCertificateServerURL:(NSString *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _certificateURL = url;
    
    return self;
}

#pragma mark - Certificate Retrieval

- (void)retrieveNewCertificateWithAppId:(NSString *)appId completionHandler:(SDLCertificateRetrievedHandler)completionHandler {
    SDLSecurityLogD(@"Performing network request for a certificate");

    NSArray<NSURLQueryItem *> *queryItems = @[[[NSURLQueryItem alloc] initWithName:@"appId" value:appId]];
    NSURLComponents *queryComponents = [NSURLComponents componentsWithString:self.certificateURL];
    queryComponents.queryItems = queryItems;
    NSURL *url = queryComponents.URL;

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 20.0;

    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data.length == 0) {
            SDLSecurityLogE(@"No data returned");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNoCertificate userInfo:@{NSLocalizedDescriptionKey: @"Network request did not return data"}]);
        }

        NSError *jsonError = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError != nil || jsonDictionary == nil) {
            SDLSecurityLogE(@"Error parsing network request data");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeNoCertificate userInfo:@{NSLocalizedDescriptionKey: @"Network request did not return a certificate"}]);
        }

        NSData *certificateData = [[NSData alloc] initWithBase64EncodedData:[jsonDictionary valueForKeyPath:@"data.certificate"] options:0];
        if (certificateData.length == 0) {
            SDLSecurityLogE(@"Certificate is invalid");
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:@{NSLocalizedDescriptionKey: @"Certificate is invalid"}]);
        }

        // Save the certificate to disk
        NSError *writeFileError = nil;
        [weakSelf.class sdl_deleteCertificate];
        BOOL writeSuccess = [certificateData writeToFile:[weakSelf.class sdl_certificateFilePath] options:0 error:&writeFileError];
        if (!writeSuccess) {
            SDLSecurityLogE(@"Error writing certificate to disk: %@", writeFileError.localizedDescription);
            return completionHandler(NO, [NSError errorWithDomain:SDLSecurityErrorDomain code:SDLTLSErrorCodeCertificateInvalid userInfo:@{NSLocalizedDescriptionKey: writeFileError.localizedDescription}]);
        }

        SDLSecurityLogD(@"Certificate downloaded successfully");
        return completionHandler(YES, nil);
    }];

    [task resume];
}

#pragma mark - Certificate Caching

/// Creates the directory where the PFX file will be cached
+ (NSString *)sdl_buildSecurityDirectory {
    SDLSecurityLogD(@"Creating certificate directory");

    // Place the PFX file in the application directory path
    // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];

    // The security directory has to be customized per vendor
    NSString *securityDirectoryName = [NSString stringWithFormat:@"sdl_security_%@", VendorName];
    NSString *securityPath = [documentsPath stringByAppendingPathComponent:securityDirectoryName];

    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:securityPath]) {
        NSError *directoryCreationError = nil;

        // Create the directory if it doesn't exist. Create the intermediate directories as the "Application Support" directory not exist in the app's sandbox by default.
        [[NSFileManager defaultManager] createDirectoryAtPath:securityPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        if (directoryCreationError != nil) {
            SDLSecurityLogE(@"Error creating certificate directory: %@", directoryCreationError);
        }
    } else {
        SDLSecurityLogD(@"Certificate directory already exists");
    }
    
    return securityPath;
}

/// The absolute file path of the cached PFX file
+ (NSString *)sdl_certificateFilePath {
    NSString *securityPath = [self sdl_buildSecurityDirectory];
    NSString *certificatePath = [securityPath stringByAppendingPathComponent:@"cert.pfx"];
    
    return certificatePath;
}

/// Deletes the cached PFX file, if it extists.
+ (void)sdl_deleteCertificate {
    SDLSecurityLogD(@"Deleting certificate");
    NSString *certificatePath = [self sdl_certificateFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:certificatePath]) {
        SDLSecurityLogD(@"No certificate to delete");
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:certificatePath error:nil];
}

- (nullable NSData *)certificateData {
    NSString *certPath = [[self class] sdl_certificateFilePath];
    if (![[NSFileManager defaultManager] isReadableFileAtPath:certPath]) {
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:certPath];
}

@end

NS_ASSUME_NONNULL_END
