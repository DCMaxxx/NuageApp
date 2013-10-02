//
//  NAAppDelegate.h
//  NuageApp Server
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <DTBonjourServer.h>
#import <Cocoa/Cocoa.h>

@interface NAAppDelegate : NSObject <NSApplicationDelegate, DTBonjourServerDelegate, NSUserNotificationCenterDelegate>

@property (unsafe_unretained) IBOutlet NSWindow *window;

@end
