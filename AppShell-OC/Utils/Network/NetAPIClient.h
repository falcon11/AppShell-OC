//
//  NetAPIClient.h
//  weiju-ios
//
//  Created by ashoka on 22/03/2017.
//  Copyright © 2017 evideo. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "NetAPIHeaders.h"

@interface NetAPIClient : AFHTTPSessionManager

@property (nonatomic, assign) BOOL debugMode;

+ (instancetype)sharedJsonClient;
+ (instancetype)changeJsonClient;

- (instancetype)initWithBaseURL:(NSURL *)url;

- (void)setHttpRequestHeaders:(NSDictionary *)headers;

/**
 used to request json data, default auto show error

 @param aPath path
 @param params a dictionary
 @param method [get, post, put, delete]
 @param block callback
 */
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       completion:(APICompletion)block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       completion:(void (^)(id data, NSError *error))block;

/**
 current api server base url

 @return return the baseUrl set in the info.plist or set through + (void)changeUrl:(NSString *)url
 */
+ (NSString *)baseURLStr;


/**
 change the server base url

 @param url new server base url, once setted it will overwritter the orignal one and stored in standardUserDefaults
 */
+ (void)changeUrl:(NSString *)url;

@end
