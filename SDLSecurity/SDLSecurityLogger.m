//
//  SDLSecurityLogger.m
//  SDLSecurity
//
//  Created by Joel Fischer on 9/5/19.
//  Copyright © 2019 livio. All rights reserved.
//

#import "SDLSecurityLogger.h"

#import <asl.h>

#import "SDLSecurityManager.h"

@implementation SDLSecurityLogger

+ (SDLSecurityLogger *)shared {
    static SDLSecurityLogger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SDLSecurityLogger alloc] init];
    });

    return shared;
}

- (instancetype)init {
    self = [super init];
    if (!self) { return nil; }

    return self;
}

- (void)logWithLevel:(LoggerLevel)level timestamp:(NSDate *)timestamp message:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *formatMessage = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    NSString *logString = [NSString stringWithFormat:@"%@ %@ %@ (SDL)SecurityLibrary (%@) – %@\n", [self.class.dateFormatter stringFromDate:timestamp], [self sdl_logCharacterForLevel:level], [self sdl_logNameForLevel:level], [SDLSecurityManager availableMakes], formatMessage];

    const char *charLog = [logString UTF8String];
    int result = asl_log_message(ASL_LEVEL_ERR, "%s", charLog);
    if (result != 0) {
        NSLog(@"Error logging to ASL log, logging to NSLog instead:\n%@", logString);
    }
}

- (NSString *)sdl_logCharacterForLevel:(LoggerLevel)logLevel {
    switch (logLevel) {
        case LoggerLevelDebug: return @"🔵";
        case LoggerLevelWarning: return @"🔶";
        case LoggerLevelError: return @"❌";
        default:
            NSAssert(NO, @"The OFF and DEFAULT log levels are not valid to log with.");
            return @"";
    }
}

- (NSString *)sdl_logNameForLevel:(LoggerLevel)logLevel {
    switch (logLevel) {
        case LoggerLevelDebug: return @"DEBUG";
        case LoggerLevelWarning: return @"WARNING";
        case LoggerLevelError: return @"ERROR";
        default:
            NSAssert(NO, @"The OFF and DEFAULT log levels are not valid to log with.");
            return @"UNKNOWN";
    }
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm:ss:SSS";
    });

    return _dateFormatter;
}

@end
