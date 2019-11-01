//
//  SDLSecurityLogger.h
//  SDLSecurity
//
//  Created by Joel Fischer on 9/5/19.
//  Copyright © 2019 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// An enum describing the severity level of the log message.
/// LoggerLevelOff: Not used
/// LoggerLevelError: A non-recoverable error occured
/// LoggerLevelWarning: An error occured but it is recoverable
/// LoggerLevelDebug: Detailed summary information
typedef NS_ENUM(NSInteger, LoggerLevel) {
    LoggerLevelOff = 0,
    LoggerLevelError = 1,
    LoggerLevelWarning = 2,
    LoggerLevelDebug = 3
};

/// A singleton class for printing formatted debug logs to the console.
@interface SDLSecurityLogger : NSObject

/// Singleton
+ (SDLSecurityLogger *)shared;

/// Logs a message to the console.
/// @param level The log level and corresponding icon to print along with the message
/// @param timestamp The timestamp of when the message was run
/// @param message The message to be logged
- (void)logWithLevel:(LoggerLevel)level timestamp:(NSDate *)timestamp message:(NSString *)message, ... NS_FORMAT_FUNCTION(3, 4);

@end

NS_ASSUME_NONNULL_END
