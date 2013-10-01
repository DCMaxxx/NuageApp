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

@property (weak, nonatomic) IBOutlet NATextFieldCell *currentPasswordCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *updatedPasswordCell;
@property (strong, nonatomic) NSString * connectionIdentifier;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangePasswordViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NAAPIEngine sharedEngine] addDelegate:self];
    }
    return self;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NAAPIEngine sharedEngine] setClearsCookies:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_connectionIdentifier) {
        [[NAAPIEngine sharedEngine] cancelConnection:_connectionIdentifier];
        [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    }
    [[NAAPIEngine sharedEngine] removeDelegate:self];
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
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        [MBProgressHUD showHUDAddedTo:[self view] withText:@"Updating account..." showActivityIndicator:YES animated:YES];
        _connectionIdentifier = [[NAAPIEngine sharedEngine] changeToPassword:updatedPassword
                                                         withCurrentPassword:currentPassword
                                                                    userInfo:self];
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
    _connectionIdentifier = nil;
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[NAAPIEngine sharedEngine] setCurrentAccount:account];
    [[NAAPIEngine sharedEngine] setClearsCookies:NO];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[NAAPIEngine sharedEngine] setClearsCookies:NO];
    
    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

@end
