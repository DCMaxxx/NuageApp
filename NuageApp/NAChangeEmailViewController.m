//
//  NAChangeEmailViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAChangeEmailViewController.h"

#import "MBProgressHUD+Network.h"
#import "NATextFieldCell.h"
#import "NSError+Network.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NAChangeEmailViewController () <CLAPIEngineDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (weak, nonatomic) IBOutlet NATextFieldCell *emailCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *passwordCell;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangeEmailViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];

    [[_emailCell textField] setPlaceholder:@"New email address"];
    [[_emailCell textField] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[_emailCell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[_emailCell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [[_passwordCell textField] setPlaceholder:@"Current password"];
    [[_passwordCell textField] setSecureTextEntry:YES];
}

/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
    [[_emailCell textField] setText:[[_engine currentAccount] email]];
    [[self tableView] reloadData];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedSaveButton:(id)sender {
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [MBProgressHUD showHUDAddedTo:[self view] withText:@"Updating account..." showActivityIndicator:YES animated:YES];
        [_engine setClearsCookies:YES];
        [_engine changeToEmail:email withPassword:password userInfo:nil];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Both email and password fields are required"];
        [av show];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)accountUpdateDidSucceed:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [_engine setCurrentAccount:account];
    [_engine setClearsCookies:NO];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [_engine setClearsCookies:NO];

    NAAlertView * av;
    if ([error isNetworkError]) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else if ([error code] == NSURLErrorUnknown && [[error userInfo][@"statusCode"] isEqual:@(500)]) { // Bad password
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedLogin];
        [av setMessage:@"Please check your password"];
    } else if ([error code] == NSURLErrorUnknown && [[error userInfo][@"statusCode"] isEqual:@(204)]) { // Bad email
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedLogin];
        [av setMessage:@"Please check your new email address"];
    } else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error on NAChangeEmailViewController : %@", error);
    }
    [av show];
}

@end
