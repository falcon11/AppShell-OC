//
//  Logger.h
//  AppShell-OC
//
//  Created by Ashoka on 01/01/2018.
//  Copyright © 2018 Ashoka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface Logger : NSObject

+ (void)setupLogger;

@end
