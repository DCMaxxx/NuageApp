//
//  NAAlertView.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 31/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAlertView.h"


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAlertView

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithNAAlertViewKind:(NAAlertViewKind)kind {
    NSArray * titles = @[@"Missing field",
                         @"Failed loggin in",
                         @"Failed registering",
                         @"Network error",
                         @"Premium account feature",
                         @"Unactivated account",
                         @"Oops"];
    NSArray * messages = @[@"Please fill required fields",
                           @"Please check your email and password",
                           @"Please try another email address or try again later",
                           @"Please verify your network status",
                           @"You need a premium CloudApp account to perform this action",
                           @"You need to activate your account, by clicking on the link in CloudApp's confirmation email.",
                           @"Something went wrong. Please try again later"];

    assert([titles count] == kAVNone && [messages count] == kAVNone);
    
    return self = [super initWithTitle:titles[kind]
                               message:messages[kind]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
}

@end
