//
//  SDLCertificateManagerTests.m
//  SDLSecurity
//
//  Created by Joel Fischer on 2/29/16.
//  Copyright © 2016 livio. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "_SDLCertificateManager.h"


static NSString *const TestAppId = @"000000000";


@interface SDLCertificateManagerTests : XCTestCase

@property (strong, nonatomic) _SDLCertificateManager *certManager;

@end


@implementation SDLCertificateManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.certManager = [[_SDLCertificateManager alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *expectation = [self expectationWithDescription:@"Certificate Expectation"];
    
    [self.certManager retrieveNewCertificateWithAppId:TestAppId completionHandler:^(BOOL success, NSError * _Nullable error) {
        XCTAssertTrue(success);
        
        if (!success) {
            NSLog(@"TEST Error retrieving certificate: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Timeout waiting for certificate");
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
