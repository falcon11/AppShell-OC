//
//  AppShell_OCTests.m
//  AppShell-OCTests
//
//  Created by Ashoka on 28/12/2017.
//  Copyright © 2017 Ashoka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppPrefixHeader.pch"

#define DebugLog(s, ...) NSLog(@"%s(%d): \n%@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

@interface AppShell_OCTests : XCTestCase {
    XCTestExpectation* expectation;
}
@end

@implementation AppShell_OCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Logger setupLogger];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testNetAPIClient {
    expectation = [self expectationWithDescription:@"test network call"];
    [APIManager.sharedManager requestWithPath:@"headers" withParams:nil method:Get completion:^(id data, NSError *error) {
        DDLogDebug(@"error: %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testLogger {
    DDLogVerbose(@"hello");
    DDLogDebug(@"debug hello");
    DDLogError(@"error...");
    DDLogInfo(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
}

- (void)testViewFrame {
    UIView *v = [UIView new];
    v.x = 1;
    DDLogDebug(@"frame:%@", NSStringFromCGRect(v.frame));
}


@end
