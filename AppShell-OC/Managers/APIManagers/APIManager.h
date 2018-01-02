//
//  APIManager.h
//  AppShell-OC
//
//  Created by Ashoka on 30/12/2017.
//  Copyright © 2017 Ashoka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (instancetype)sharedManager;

- (void)requestWithPath:(NSString *)path withParams:(NSDictionary *)params method:(NetworkMethod)method completion:(APICompletion)completion;

- (void)requestWithPath:(NSString *)path withParams:(NSDictionary *)params method:(NetworkMethod)method autoHandleError:(BOOL)autoHandleError completion:(APICompletion)completion;

@end
