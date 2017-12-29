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

+ (instancetype)sharedJsonClient {
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", [self baseURLStr]]]];
    });
    return _sharedClient;
}
+ (instancetype)changeJsonClient {
    _sharedClient = [[NetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", [self baseURLStr]]]];
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
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
    
    self.debugMode = NO;
    
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
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
    __weak typeof(self) weakSelf = self;
    //    发起请求
    switch (method) {
        case Get:{
            [self GET:aPath parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakSelf handleSuccess:task responseObject:responseObject autoShowError:autoShowError completion:block];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakSelf handleFailure:task error:error autoShowError:autoShowError completion:block];
            }];
            break;}
        case Post:{
            [self POST:aPath parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakSelf handleSuccess:task responseObject:responseObject autoShowError:autoShowError completion:block];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakSelf handleFailure:task error:error autoShowError:autoShowError completion:block];
            }];
            break;}
        case Put:{
            [self PUT:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                [weakSelf handleSuccess:task responseObject:responseObject autoShowError:autoShowError completion:block];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf handleFailure:task error:error autoShowError:autoShowError completion:block];
            }];
            break;}
        case Delete:{
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                [weakSelf handleSuccess:task responseObject:responseObject autoShowError:autoShowError completion:block];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf handleFailure:task error:error autoShowError:autoShowError completion:block];
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

- (void)handleSuccess:(NSURLSessionDataTask *)task responseObject:(id)responseObject autoShowError:(BOOL)autoShowError completion:(void (^)(id data, NSError *error))completion{
    DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", task.originalRequest.URL.relativePath, responseObject);
    id error = [self handleResponse:responseObject autoShowError:autoShowError];
    if (error) {
        completion(nil, error);
    }else{
        completion(responseObject, nil);
    }
}

- (void)handleFailure:(NSURLSessionDataTask *)task error:(NSError *)error autoShowError:(BOOL)autoShowError completion:(void (^)(id data, NSError *error))completion {
    DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", task.originalRequest.URL.relativePath, error.localizedDescription, task.response);
    completion(nil, error);
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
