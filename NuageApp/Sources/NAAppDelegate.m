//
//  NAAppDelegate.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 27/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAppDelegate.h"

#import <PKRevealController.h>
#import <AFNetworking.h>
#import <GAI.h>

#import "NASettingsViewController.h"
#import "NAMenuViewController.h"
#import "NACopyHandler.h"

#define kGAITrackingId @"UA-44631088-1"


@implementation NAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingId];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [NACopyHandler sharedInstance];
    
    NAMenuViewController * rearVC = (NAMenuViewController *)[[self window] rootViewController];
    UIViewController * frontVC = [rearVC viewControllers][0];
    PKRevealController * revealController = [PKRevealController revealControllerWithFrontViewController:frontVC leftViewController:rearVC options:@{PKRevealControllerRecognizesPanningOnFrontViewKey:@(NO)}];
    [[self window] setRootViewController:revealController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAApplicationWillEnterForeground" object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAApplicationWillEnterForeground" object:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
