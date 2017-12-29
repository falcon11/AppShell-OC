//
//  AppShell_OCTests.m
//  AppShell-OCTests
//
//  Created by Ashoka on 28/12/2017.
//  Copyright © 2017 Ashoka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NetAPIClient.h"

@interface AppShell_OCTests : XCTestCase {
    
}
@end

@implementation AppShell_OCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [NetAPIClient changeUrl:@"http://httpbin.org"];
    NetAPIClient.sharedJsonClient.debugMode = YES;
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
    XCTestExpectation* expectation = [self expectationWithDescription:@"test network call"];
    [[NetAPIClient sharedJsonClient] requestJsonDataWithPath:@"headers" withParams:@{@"p1":@"abc"} withMethodType:Get andBlock:^(id data, NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:10];
}

@end
