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

#import "NAAutoUploadViewController.h"
#import "NAMainViewController.h"
#import "NABonjourClient.h"


@implementation NAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [NABonjourClient sharedInstance];

    UIStoryboard * rearStoryboard = [UIStoryboard storyboardWithName:@"RearStoryboard" bundle:nil];
    NAMainViewController * rearVC = [rearStoryboard instantiateInitialViewController];
    UIViewController * frontVC = [rearVC viewControllers][0];
    PKRevealController * revealController = [PKRevealController revealControllerWithFrontViewController:frontVC leftViewController:rearVC options:nil];
    [[self window] setRootViewController:revealController];
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
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[[self window] rootViewController] isKindOfClass:[PKRevealController class]]) {
        PKRevealController * reavealController = (PKRevealController *)[[self window] rootViewController];
        if ([[reavealController leftViewController] isKindOfClass:[NAMainViewController class]]) {
            NAMainViewController * mainViewController = (NAMainViewController *)[reavealController leftViewController];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoUploadKey])
                [mainViewController displayUploadConfirmAlertView];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
