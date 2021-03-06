//
//  main.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 27/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAppDelegate.h"

/*----------------------------------------------------------------------------*/
#pragma mark - Original main
/*----------------------------------------------------------------------------*/
//int main(int argc, char *argv[])
//{
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NAAppDelegate class]));
//    }
//}


/*----------------------------------------------------------------------------*/
#pragma mark - iOS7 fucking assert macro workaround
/*----------------------------------------------------------------------------*/
typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
        return 0;
    }
    return _oldStdWrite(inFD, buffer, size);
}

int main(int argc, char *argv[])
{
    _oldStdWrite = stderr->_write;
    stderr->_write = __pyStderrWrite;
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NAAppDelegate class]));
    }
}
