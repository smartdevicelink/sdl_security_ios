//
//  SDLTLSEngineTests.m
//  SDLSecurity
//
//  Created by Joel Fischer on 2/24/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SDLTLSEngine.h"

static NSString *const TestAppId = @"584421907";


@interface SDLTLSEngineTests : XCTestCase

@property (strong, nonatomic) SDLTLSEngine *tlsEngine;

@end


@implementation SDLTLSEngineTests

+ (NSString *)pfxCertificatePath {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [testBundle pathForResource:@"TestCertificate" ofType:@"pfx"];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.tlsEngine = [[SDLTLSEngine alloc] initWithAppId:TestAppId];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.tlsEngine shutdownTLS];
    
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testTLSInitialization {
    NSString *p12Location = [self.class pfxCertificatePath];
    NSData *p12Data = [NSData dataWithContentsOfFile:p12Location];
    
    NSError *error = nil;
    BOOL success = [self.tlsEngine initializeTLSWithCertificateData:p12Data error:&error];
    
    XCTAssertTrue(success);
    XCTAssertNil(error);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
