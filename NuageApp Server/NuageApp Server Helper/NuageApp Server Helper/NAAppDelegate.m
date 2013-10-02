//
//  NAAppDelegate.m
//  NuageApp Server Helper
//
//  Created by Maxime de Chalendar on 10/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAppDelegate.h"

#define kNumberOfLastPathComponents 3

/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAppDelegate

/*----------------------------------------------------------------------------*/
#pragma mark - NSApplicationDelegate
/*----------------------------------------------------------------------------*/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    BOOL alreadyRunning = NO;
    NSArray * running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running)
        if ([[app bundleIdentifier] isEqualToString:@"com.maxime-dechalendar.NuageApp-Server"])
            alreadyRunning = YES;
    
    if (!alreadyRunning) {
        NSString * path = [[NSBundle mainBundle] bundlePath];
        NSMutableArray * pathComponents = [[path pathComponents] mutableCopy];
        for (int i = 0; i < kNumberOfLastPathComponents; ++i)
            [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:@"NuageApp Server"];
        NSString * fullPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:fullPath];
    }
    [NSApp terminate:self];
}

@end
