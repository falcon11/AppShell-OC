//
//  APIManager.m
//  AppShell-OC
//
//  Created by Ashoka on 30/12/2017.
//  Copyright © 2017 Ashoka. All rights reserved.
//

#define DebugLog(s, ...) NSLog(@"%s(%d): \n%@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#import "APIManager.h"

@implementation APIManager

+ (instancetype)sharedManager {
    static APIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[APIManager alloc] init];
        
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        change to your server url here
        [NetAPIClient changeUrl:@"http://httpbin.org"];
        NetAPIClient.sharedJsonClient.debugMode = YES;
    }
    return self;
}

- (void)refreshToken:(APICompletion)completion {
//    refresh token here
    [self baseRequestWithPath:@"headers" params:@{@"account": @"abc", @"password": @"123"} method:Get completion:^(id data, NSError *error) {
        if (!error && completion) { completion(data, nil); }
        else {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)requestWithPath:(NSString *)path withParams:(NSDictionary *)params method:(NetworkMethod)method completion:(APICompletion)completion {
    [self requestWithPath:path withParams:params method:method autoHandleError:YES completion:completion];
}


/**
 if token expired, this request will automatically refresh token and repeat request
 
 @param path <#path description#>
 @param params <#params description#>
 @param method <#method description#>
 @param autoHandleError <#autoHandleError description#>
 @param completion <#completion description#>
 */
- (void)requestWithPath:(NSString *)path withParams:(NSDictionary *)params method:(NetworkMethod)method autoHandleError:(BOOL)autoHandleError completion:(APICompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self baseRequestWithPath:path params:params method:method completion:^(id data, NSError *error) {
        DebugLog(@"response data: %@", data);
        if (!error && completion) completion(data, nil);
        else if ([self isTokenExpired:error]){
            [self refreshToken:^(id data, NSError *error) {
                if (!error) {
                    [weakSelf baseRequestWithPath:path params:params method:method completion:^(id data, NSError *error) {
                        if (!error && completion) completion(data, nil);
                        else {
                            if (autoHandleError) [weakSelf handleError:error];
                            if (completion) completion(nil, error);
                        }
                    }];
                } else {
                    if (autoHandleError) [weakSelf handleError:error];
                    if (completion) completion(nil, error);
                }
            }];
        } else {
            if (autoHandleError) [weakSelf handleError:error];
            if (completion) completion(nil, error);
        }
    }];
}

- (void)baseRequestWithPath:(NSString *)path params:(NSDictionary *)params method:(NetworkMethod)method completion:(APICompletion)completion {
    __weak typeof (self) weakSelf = self;
    [NetAPIClient.sharedJsonClient requestJsonDataWithPath:path withParams:params withMethodType:method completion:^(id data, NSError *error) {
        if (!completion) return;
        [weakSelf parseResponse:data error:error completion:^(id data, NSError *error) {
            if (!error) completion(data, nil);
            else {
                completion(nil, error);
            }
        } ];
    }];
}

- (void)parseResponse:(id)response error:(NSError *)error completion:(APICompletion)completion {
    //    add respons parse and error parse code here
    if (completion) completion(response, error);
}

- (void)handleError:(NSError *)error {
    //    handle error here if autoHandleError == YES
}

- (BOOL)isTokenExpired:(NSError *)error {
    return NO;
}

@end
