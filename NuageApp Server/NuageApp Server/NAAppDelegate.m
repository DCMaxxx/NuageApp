//
//  NAAppDelegate.m
//  NuageApp Server
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>


@implementation NAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage * icon = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"baricon" ofType: @"png"]];
    NSImage * selectedIcon = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"barselectedIcon" ofType: @"png"]];

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:icon];
    [statusItem setAlternateImage:selectedIcon];
    [statusItem setHighlightMode:YES];
    
    if ([self isLaunchAtStartupEnabled])
        [_launchAtStartup setState:NSOnState];

    server = [[DTBonjourServer alloc] initWithBonjourType:@"_NuageApp._tcp."];
    [server setDelegate:self];
    [server start];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSURL * url = [NSURL URLWithString:[notification informativeText]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)bonjourServer:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection {
    if ([object isKindOfClass:[NSString class]]) {
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:object forType:NSPasteboardTypeString];
        
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Nuage Drop copied to clipboard"];
        [notification setInformativeText:object];
        [notification setSoundName:NSUserNotificationDefaultSoundName];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

- (IBAction)tappedQuitButton:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)tappedLaunchAtStartupButton:(id)sender {
    [self setLaunchAtStartupValue:![self isLaunchAtStartupEnabled]];
}

- (BOOL)isLaunchAtStartupEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"launch-at-startup"];
}

- (void)setLaunchAtStartupValue:(BOOL)launchAtStartup {
    if (SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.maxime-dechalendar.NuageApp-Server-Helper", launchAtStartup)) {
        [_launchAtStartup setState:(launchAtStartup ? NSOnState : NSOffState)];
        [[NSUserDefaults standardUserDefaults] setBool:launchAtStartup forKey:@"launch-at-startup"];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                         defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Oops. You might want to try again. Sorry for the inconvenience !"];
        [alert runModal];

    }
}

@end
