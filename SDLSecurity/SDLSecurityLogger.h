//
//  SDLSecurityLogger.h
//  SDLSecurity
//
//  Created by Joel Fischer on 9/5/19.
//  Copyright © 2019 livio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LoggerLevel) {
    LoggerLevelOff = 0,
    LoggerLevelError = 1,
    LoggerLevelWarning = 2,
    LoggerLevelDebug = 3
};

@interface SDLSecurityLogger : NSObject

+ (SDLSecurityLogger *)shared;

- (void)logWithLevel:(LoggerLevel)level timestamp:(NSDate *)timestamp message:(NSString *)message, ... NS_FORMAT_FUNCTION(3, 4);

@end

NS_ASSUME_NONNULL_END
