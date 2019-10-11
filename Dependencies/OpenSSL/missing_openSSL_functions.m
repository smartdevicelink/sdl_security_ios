//
//  missing_openSSL_functions.m
//  SDLSecurity
//
//  Created by Nicole on 9/20/19.
//  Copyright © 2019 livio. All rights reserved.
//
//  Fixes linker errors thrown while building an iOS project with this library on an Xcode simulator. The following errors are thrown:
//      * Undefined symbol: _readdir$INODE64
//      * Undefined symbol: _opendir$INODE64
//  This fix based on solution here: https://stackoverflow.com/questions/29390112/libcrypto-a-symbols-not-found-for-architecture-i386

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <fnmatch.h>

DIR * opendir$INODE64(char * dirName) {
    return opendir(dirName);
}

struct dirent * readdir$INODE64(DIR * dir) {
    return readdir(dir);
}


