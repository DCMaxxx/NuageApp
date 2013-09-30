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
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NAChangeEmailViewController () <CLAPIEngineDelegate>

@property (weak, nonatomic) IBOutlet NATextFieldCell *emailCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *passwordCell;
@property (strong, nonatomic) NSString * connectionIdentifier;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangeEmailViewController

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

    [[_emailCell textField] setPlaceholder:@"New email address"];
    [[_emailCell textField] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[_emailCell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[_emailCell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [[_passwordCell textField] setPlaceholder:@"Current password"];
    [[_passwordCell textField] setSecureTextEntry:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[_emailCell textField] setText:[[[NAAPIEngine sharedEngine] currentAccount] email]];
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
- (IBAction)tappedSaveButton:(id)sender {
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [[_emailCell textField] resignFirstResponder];
        [[_passwordCell textField] resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:[self view] withText:@"Updating account..." showActivityIndicator:YES animated:YES];
        [[NAAPIEngine sharedEngine] setClearsCookies:YES];
        _connectionIdentifier = [[NAAPIEngine sharedEngine] changeToEmail:email withPassword:password userInfo:self];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
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
