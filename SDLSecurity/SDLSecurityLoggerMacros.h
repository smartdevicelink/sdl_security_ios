//
//  SDLSecurityLoggerMacros.h
//  SDLSecurity
//
//  Created by Joel Fischer on 9/5/19.
//  Copyright © 2019 livio. All rights reserved.
//

#import "SDLSecurityLogger.h"

#ifndef SDLSecurityLoggerMacros_h
#define SDLSecurityLoggerMacros_h

/// Log a debug log
/// @param msg The format string to log
/// @param ... The format arguments to log
#define SDLSecurityLogD(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelDebug timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

/// Log a warning log
/// @param msg The format string to log
/// @param ... The format arguments to log
#define SDLSecurityLogW(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelWarning timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

/// Log an error log
/// @param msg The format string to log
/// @param ... The format arguments to log
#define SDLSecurityLogE(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelError timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

#endif /* SDLSecurityLoggerMacros_h */
