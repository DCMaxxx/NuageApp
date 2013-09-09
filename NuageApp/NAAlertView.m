//
//  NAAlertView.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 31/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAlertView.h"

#import "CLAPIEngineConstants.h"

#define kStatusCodeRegisteringEmailInvalid      422
#define kStatusCodeRegisteringEmailInUse        406
#define kStatusCodeLoginUnactivatedAccount      409
#define kStatusCodeUpdateCurrentPasswordInvalid 500
#define kStatusCodeOther                        204


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
                         @"Failed to upload your file",
                         @"Network error",
                         @"Premium account feature",
                         @"Oops"];
    NSArray * messages = @[@"Please fill required fields",
                           @"Please check your email and password",
                           @"Please try another email address or try again later",
                           @"Please try again later",
                           @"Please verify your network status",
                           @"You need a premium CloudApp account to perform this action",
                           @"Something went wrong. Please try again later"];

    NSAssert([titles count] == kAVNone && [messages count] == kAVNone, @"Please update NAAlertViewWithKind messages");
    
    return self = [super initWithTitle:titles[kind]
                               message:messages[kind]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
}

- (id)initWithError:(NSError *)error userInfo:(id)userInfo {
    NSLog(@"Error : %@", error);
    
    NAAlertViewKind kind = kAVGeneric;
    NSString * title = nil;
    NSString * message = nil;
    switch ([error code]) {
        case NSURLErrorUserCancelledAuthentication:
            kind = kAVFailedLogin;
            break;
        case CLAPIEngineErrorUploadLimitExceeded:
            kind = kAVFailedUpload;
            message = @"You've already uploaded ten drops today. If you want more, you can switch to a premium account";
            break ;
        case CLAPIEngineErrorUploadTooLarge:
            kind = kAVFailedUpload; // Change
            message = @"File is too large. Please resize it before trying again";
            break;
        case CLAPIEngineErrorUnknown: {
            if (![[error userInfo] isKindOfClass:[NSDictionary class]])
                kind = kAVGeneric;
                break;
            switch ([[error userInfo][CLAPIEngineErrorStatusCodeKey] integerValue]) {
                case kStatusCodeRegisteringEmailInvalid:
                    kind = kAVFailedRegistering;
                    message = @"Your email must look like an email address";
                    break;
                case kStatusCodeRegisteringEmailInUse:
                    kind = kAVFailedRegistering;
                    message = @"This email is already in use";
                    break;
                case kStatusCodeLoginUnactivatedAccount:
                    kind = kAVFailedLogin;
                    message = @"This account needs to be activated. Please check your email for CloudApp activation link";
                    break;
                case kStatusCodeUpdateCurrentPasswordInvalid:
                    kind = kAVFailedLogin;
                    message = @"Please check your current password";
                    break;
                case kStatusCodeOther:
                    kind = kAVGeneric;
                default:
                    NSLog(@"Other error : %@", error);
                    break;
            }
            break;
        }
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorTimedOut:
            kind = kAVNetwork;
            break;
        default:
            kind = kAVGeneric;
            break;
    }

    if (self = [[NAAlertView alloc] initWithNAAlertViewKind:kind]) {
        if (title)
            [self setTitle:title];
        if (message)
            [self setMessage:message];
    }
    return self;
}


@end
