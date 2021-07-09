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
typedef NS_ENUM(NSInteger, LoggerLevel) {
    /// Not used
    LoggerLevelOff = 0,
    /// A non-recoverable error occured
    LoggerLevelError = 1,
    /// An error occured but it is recoverable
    LoggerLevelWarning = 2,
    /// Detailed summary
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
