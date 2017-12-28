//
//  NetAPIClient.m
//  weiju-ios
//
//  Created by ashoka on 22/03/2017.
//  Copyright © 2017 evideo. All rights reserved.
//

#define DebugLog(s, ...) if(self.debugMode) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define kNetworkMethodName @[@"Get", @"Post", @"Put", @"Delete"]
#define kServerUrl @"ServerUrl"


#import "NetAPIClient.h"

@implementation NetAPIClient

static NetAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (id)sharedJsonClient {
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", [self baseURLStr]]]];
    });
    return _sharedClient;
}
+ (id)changeJsonClient {
    _sharedClient = [[NetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", [self baseURLStr]]]];
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    AFHTTPResponseSerializer *httpResponseSerializer = [AFHTTPResponseSerializer serializer];
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    self.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonResponseSerializer, httpResponseSerializer]];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json;version=1" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"weiju2_app" forHTTPHeaderField:@"appname"];
    [self.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    self.securityPolicy.allowInvalidCertificates = YES;
    self.securityPolicy.validatesDomainName = NO;
    
    self.debugMode = YES;
    
    return self;
}

+ (NSString *)baseURLStr{
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:kServerUrl];
    if (!url) {
        NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        url = [dict objectForKey:kServerUrl];
    }
    return url;
}

+ (void)changeUrl:(NSString *)url {
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:kServerUrl];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block {
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method autoShowError:YES andBlock:block];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block {
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
    DebugLog(@"\n===========request===========\nmethod:%@\npath:%@\nparams:%@", kNetworkMethodName[method], aPath, params);
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    发起请求
    switch (method) {
        case Get:{
            [self GET:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(responseObject, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", aPath, error, task.response);
                block(nil, error);
            }];
            break;}
        case Post:{
            [self POST:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", aPath, error, task.response);
                block(nil, error);
            }];
            break;}
        case Put:{
            [self PUT:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", aPath, error, task.response);
                block(nil, error);
            }];
            break;}
        case Delete:{
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", aPath, error, task.response);
                block(nil, error);
            }];
            break;}
        default:
            break;
    }
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block {
    
}

- (id)handleResponse:responseObject autoShowError:(BOOL)autoShowError {
    NSError *error = nil;
    if (![responseObject isKindOfClass:[NSDictionary class]] || ![responseObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    if ([responseObject[@"ret"] intValue]!=0) {
        error = [NSError errorWithDomain:[NetAPIClient baseURLStr] code:99999 userInfo:responseObject];
        if (self.tokenExpiredBlock) {
            self.tokenExpiredBlock(error);
        }
        return error;
    } else {
        return nil;
    }

}

- (void)startSessionWithToken:(NSString *)token {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}

@end
