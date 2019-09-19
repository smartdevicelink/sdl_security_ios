// https://stackoverflow.com/questions/29390112/libcrypto-a-symbols-not-found-for-architecture-i386

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <fnmatch.h>

DIR * opendir$INODE64( char * dirName )
{
    return opendir( dirName );
}

struct dirent * readdir$INODE64( DIR * dir )
{
    return readdir( dir );
}

