//
//  NAAppDelegate.h
//  NuageApp Server
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DTBonjourServer.h>

@interface NAAppDelegate : NSObject <NSApplicationDelegate, DTBonjourServerDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    DTBonjourServer * server;
}

@property (assign) IBOutlet NSWindow *window;

@end