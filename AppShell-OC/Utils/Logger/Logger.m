//
//  Logger.m
//  AppShell-OC
//
//  Created by Ashoka on 01/01/2018.
//  Copyright © 2018 Ashoka. All rights reserved.
//

#import "Logger.h"
#import "LoggerFormatter.h"

@implementation Logger

+ (void)setupLogger {
    LoggerFormatter *formatter = [LoggerFormatter new];
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    ttyLogger.logFormatter = formatter;
    [DDLog addLogger:ttyLogger];
    
    DDFileLogger *filelogger = [[DDFileLogger alloc] init];
    filelogger.rollingFrequency = 60 * 60 * 24;
    filelogger.logFileManager.maximumNumberOfLogFiles = 7;
    filelogger.logFormatter = formatter;
    [DDLog addLogger:filelogger];
}

@end
