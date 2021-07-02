//
//  SDLSecurityLogger.m
//  SDLSecurity
//
//  Created by Joel Fischer on 9/5/19.
//  Copyright © 2019 livio. All rights reserved.
//

#import "SDLSecurityLogger.h"

#import <OSLog/OSLog.h>

#import "SDLSecurityManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDLSecurityLogger ()

@property (strong, nonatomic) os_log_t logClient;

@end

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

    self.logClient = os_log_create("com.sdl.log", "Security");

    return self;
}

- (void)logWithLevel:(LoggerLevel)level timestamp:(NSDate *)timestamp message:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *formatMessage = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    NSString *logString = [NSString stringWithFormat:@"%@ %@ %@ (SDL)SecurityLibrary (%@) – %@\n", [self.class.dateFormatter stringFromDate:timestamp], [self sdl_logCharacterForLevel:level], [self sdl_logNameForLevel:level], [SDLSecurityManager availableMakes], formatMessage];

    os_log_with_type(self.logClient, [self oslogLevelForLogLevel:level], "%{public}@", logString);
}

- (os_log_type_t)oslogLevelForLogLevel:(LoggerLevel)level {
    switch (level) {
        case LoggerLevelDebug: return OS_LOG_TYPE_INFO;
        case LoggerLevelWarning: return OS_LOG_TYPE_ERROR;
        case LoggerLevelError: return OS_LOG_TYPE_FAULT;
        default:
            NSAssert(NO, @"The OFF and DEFAULT log levels are not valid to log with.");
            return OS_LOG_TYPE_DEFAULT;
    }
}

/// Returns an icon representation of the LoggerLevel enum.
/// @param logLevel The log level
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

/// Returns a string representation of the LoggerLevel enum.
/// @param logLevel The log level
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

#pragma mark - Class property getters

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

NS_ASSUME_NONNULL_END
