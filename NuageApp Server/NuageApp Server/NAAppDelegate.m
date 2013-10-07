//
//  NAAppDelegate.m
//  NuageApp Server
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Sparkle/Sparkle.h>

#define kStartOnLoginKey @"start-on-login"


@interface NAAppDelegate ()

@property (weak, nonatomic) IBOutlet SUUpdater *updater;

@property (weak, nonatomic) IBOutlet NSMenu * menu;
@property (strong, nonatomic) NSStatusItem * statusBarItem;
@property (weak, nonatomic) IBOutlet NSMenuItem *launchAtStartupMenuItem;
@property (weak, nonatomic) IBOutlet NSMenuItem *checksForUpdateMenuItem;
@property (weak, nonatomic) IBOutlet NSTextField *versionTextField;

@property (strong, nonatomic) DTBonjourServer * server;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAppDelegate

/*----------------------------------------------------------------------------*/
#pragma mark - NSApplicationDelegate
/*----------------------------------------------------------------------------*/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage * icon = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"baricon" ofType: @"png"]];
    NSImage * selectedIcon = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"barselectedIcon" ofType: @"png"]];

    NSString * versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_versionTextField setStringValue:[@"v" stringByAppendingString:versionString]];
    
    _statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [_statusBarItem setMenu:_menu];
    [_statusBarItem setImage:icon];
    [_statusBarItem setAlternateImage:selectedIcon];
    [_statusBarItem setHighlightMode:YES];
    
    if ([self isLaunchAtStartupEnabled])
        [_launchAtStartupMenuItem setState:NSOnState];
    if ([self isChecksForUpdateEnabled])
        [_checksForUpdateMenuItem setState:NSOnState];

    _server = [[DTBonjourServer alloc] initWithBonjourType:@"_NuageApp._tcp."];
    [_server setDelegate:self];
    [_server start];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NSUserNotificationCenterDelegate
/*----------------------------------------------------------------------------*/
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSURL * url = [NSURL URLWithString:[notification informativeText]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}


/*----------------------------------------------------------------------------*/
#pragma mark - DTBonjourServerDelegate
/*----------------------------------------------------------------------------*/
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


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (IBAction)tappedLaunchAtStartupButton:(id)sender {
    [self setLaunchAtStartupValue:![self isLaunchAtStartupEnabled]];
}

- (IBAction)tappedAutoUpdateButton:(id)sender {
    [self setChecksForUpdate:![self isChecksForUpdateEnabled]];
}

- (IBAction)tappedAboutNuageAppButton:(id)sender {
    NSWindow *window = [self window];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Misc private functions
/*----------------------------------------------------------------------------*/
- (BOOL)isLaunchAtStartupEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kStartOnLoginKey];
}

- (void)setLaunchAtStartupValue:(BOOL)launchAtStartup {
    if (SMLoginItemSetEnabled((__bridge CFStringRef)@"com.maxime-dechalendar.NuageApp-Server-Helper", launchAtStartup)) {
        [_launchAtStartupMenuItem setState:(launchAtStartup ? NSOnState : NSOffState)];
        [[NSUserDefaults standardUserDefaults] setBool:launchAtStartup forKey:kStartOnLoginKey];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                         defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Oops. You might want to try again. Sorry for the inconvenience !"];
        [alert runModal];
    }
}

- (BOOL)isChecksForUpdateEnabled {
    return [_updater automaticallyChecksForUpdates];
}

- (void)setChecksForUpdate:(BOOL)checkForUpdates {
    [_updater setAutomaticallyChecksForUpdates:checkForUpdates];
    [_checksForUpdateMenuItem setState:(checkForUpdates ? NSOnState : NSOffState)];
}

@end
