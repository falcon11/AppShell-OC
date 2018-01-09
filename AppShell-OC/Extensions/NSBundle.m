//
//  NSBundle.m
//  AppShell-OC
//
//  Created by Ashoka on 09/01/2018.
//  Copyright © 2018 Ashoka. All rights reserved.
//

#import "NSBundle.h"

@implementation NSBundle (Common)

+ (NSString *)appVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleID {
    return [[self mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

@end
