//
//  Logger.h
//  AppShell-OC
//
//  Created by Ashoka on 01/01/2018.
//  Copyright © 2018 Ashoka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose; // ddLogLevel 注意大小写要一致
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif  /* DEBUG */

@interface Logger : NSObject

+ (void)setupLogger;

@end
