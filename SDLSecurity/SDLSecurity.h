//
//  SDLSecurity.h
//  SDLSecurity
//
//  Created by Joel Fischer on 1/21/16.
//  Copyright © 2016 livio. All rights reserved.
//
//  Umbrella header for the SDLSecurity module. This file contains all the public header files for the project.

#import <UIKit/UIKit.h>

//! Project version number for SDLSecurity.
FOUNDATION_EXPORT double SDLSecurityVersionNumber;

//! Project version string for SDLSecurity.
FOUNDATION_EXPORT const unsigned char SDLSecurityVersionString[];

// All public headers of the SDLSecurity framework
#import <SDLSecurity/SDLSecurityConstants.h>
#import <SDLSecurity/SDLSecurityManager.h>
#import <SDLSecurity/SDLSecurityType.h> // Since this protocol is exposed in `SDLSecurityManager.h` it must also be a public header
