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

#define SDLSecurityLogD(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelDebug timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

#define SDLSecurityLogW(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelWarning timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

#define SDLSecurityLogE(msg, ...) [[SDLSecurityLogger shared] logWithLevel:LoggerLevelError timestamp:[NSDate date] message:msg, ##__VA_ARGS__]

#endif /* SDLSecurityLoggerMacros_h */
