//
//  LoggerFormatter.m
//  AppShell-OC
//
//  Created by Ashoka on 01/01/2018.
//  Copyright © 2018 Ashoka. All rights reserved.
//

#import "LoggerFormatter.h"

@implementation LoggerFormatter

- (NSString * _Nullable)formatLogMessage:(nonnull DDLogMessage *)logMessage {
    NSString *levelString = [self levelString:logMessage->_flag];
    return [NSString stringWithFormat:@"%@ | %@ | %@ @ %@ | %@ | %@",
            logMessage->_timestamp, logMessage->_fileName, logMessage->_function, @(logMessage->_line), levelString, logMessage->_message];
}

- (NSString *)levelString:(DDLogFlag)flag {
    switch (flag) {
        case DDLogFlagVerbose:
            return @"💜 VERBOSE";
        case DDLogFlagDebug:
            return @"💚 DEBUG";
        case DDLogFlagInfo:
            return @"💙 INFO";
        case DDLogFlagWarning:
            return @"💛 WARNING";
        case DDLogFlagError:
            return @"❤️ ERROR";
        default:
            return @"";
            break;
    }
}

@end
