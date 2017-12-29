//
//  NetAPIClient.h
//  weiju-ios
//
//  Created by ashoka on 22/03/2017.
//  Copyright © 2017 evideo. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

typedef void(^APICompletion)(id data, NSError* error);

@interface NetAPIClient : AFHTTPSessionManager

@property (nonatomic, copy) void(^tokenExpiredBlock)(NSError *error);

@property (nonatomic, assign) BOOL debugMode;

+ (instancetype)sharedJsonClient;
+ (instancetype)changeJsonClient;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block;


- (void)startSessionWithToken:(NSString *)token;

+ (NSString *)baseURLStr;
+ (void)changeUrl:(NSString *)url;

@end
