//
//  NetAPIClient.m
//  weiju-ios
//
//  Created by ashoka on 22/03/2017.
//  Copyright © 2017 evideo. All rights reserved.
//

#define DebugLog(s, ...) if(self.debugMode) NSLog(@"%s(%d): \n%@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
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

- (void)setHttpRequestHeaders:(NSDictionary *)headers {
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       completion:(APICompletion)completion {
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
    DebugLog(@"\n===========request===========\nmethod:%@\npath:%@\nparams:%@", kNetworkMethodName[method], aPath, params);
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
    id sucessCallback = ^(NSURLSessionDataTask* task, id responseObject) {
        DebugLog(@"\n===========response===========\npath:%@\nresponse:%@", task.originalRequest.URL.relativePath, responseObject);
        if (completion) completion(responseObject, nil);
    };
    id failureCallback = ^(NSURLSessionDataTask *task, NSError *error) {
        DebugLog(@"\n===========response===========\npath:%@\nerror:%@\nresponse:%@", task.originalRequest.URL.relativePath, error.localizedDescription, task.response);
        if (completion) completion(nil, error);
    };
    //    发起请求
    switch (method) {
        case Get:{
            [self GET:aPath parameters:params progress:nil success:sucessCallback failure:failureCallback];
            break;}
        case Post:{
            [self POST:aPath parameters:params progress:nil success:sucessCallback failure:failureCallback];
            break;}
        case Put:{
            [self PUT:aPath parameters:params success:sucessCallback failure:failureCallback];
            break;}
        case Delete:{
            [self DELETE:aPath parameters:params success:sucessCallback failure:failureCallback];
            break;}
        default:
            break;
    }
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       completion:(APICompletion)completion {
    
}

@end
