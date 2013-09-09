//
//  NAChangePasswordViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAChangePasswordViewController.h"

#import <AFNetworking.h>

#import "MBProgressHUD+Network.h"
#import "NATextFieldCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NAChangePasswordViewController () <CLAPIEngineDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;
@property (weak, nonatomic) IBOutlet NATextFieldCell *currentPasswordCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *updatedPasswordCell;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangePasswordViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[_currentPasswordCell textField] setPlaceholder:@"Current password"];
    [[_currentPasswordCell textField] setSecureTextEntry:YES];
    
    [[_updatedPasswordCell textField] setPlaceholder:@"New password"];
    [[_updatedPasswordCell textField] setSecureTextEntry:YES];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedOnSaveButton:(id)sender {
    NSString * currentPassword = [[_currentPasswordCell textField] text];
    NSString * updatedPassword = [[_updatedPasswordCell textField] text];
    if ([currentPassword length] && [updatedPassword length]) {
        [[_currentPasswordCell textField] resignFirstResponder];
        [[_updatedPasswordCell textField] resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:[self view] withText:@"Updating account..." showActivityIndicator:YES animated:YES];
        [_engine changeToPassword:updatedPassword withCurrentPassword:currentPassword userInfo:nil];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Both current and new password fields are required"];
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
    
    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
    [_engine setClearsCookies:YES];
}

@end
