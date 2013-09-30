//
//  NALoginViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 28/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NALoginViewController.h"

#import <PKRevealController.h>

#import "MBProgressHUD+Network.h"
#import "NAMenuViewController.h"
#import "NATextFieldCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NALoginViewController () <CLAPIEngineDelegate>

@property (strong, nonatomic) PKRevealController * revealController;
@property (weak, nonatomic) IBOutlet NATextFieldCell *emailCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *passwordCell;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;

@property (strong, nonatomic) NSString * connectionIdentifier;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NALoginViewController

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

    [[_emailCell textField] setPlaceholder:@"Your CloudApp email address"];
    [[_emailCell textField] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[_emailCell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[_emailCell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [[_passwordCell textField] setPlaceholder:@"Your CloudApp password"];
    [[_passwordCell textField] setSecureTextEntry:YES];    

    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 7.0) {
        UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        for (UIButton * button in @[_loginButton, _registerButton]) {
            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateHighlighted];
            [[button titleLabel] setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
        }
        [_orLabel setHidden:YES];
        [_forgotPasswordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_termsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[_emailCell textField] setText:[[NAAPIEngine sharedEngine] email]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_connectionIdentifier) {
        [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
        [[NAAPIEngine sharedEngine] cancelConnection:_connectionIdentifier];
    }
    [[NAAPIEngine sharedEngine] removeDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User actions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedLoginButton:(id)sender {
    if (_connectionIdentifier)
        return ;
    
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [[_emailCell textField] resignFirstResponder];
        [[_passwordCell textField] resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:[self view]
                             withText:@"Loggin in..."
                showActivityIndicator:YES
                             animated:YES];
        NAAPIEngine * engine = [NAAPIEngine sharedEngine];
        [engine setClearsCookies:YES];
        [engine setEmail:email];
        [engine setPassword:password];
        [engine getAccountInformationWithUserInfo:self];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Both email and password fields are requierd"];
        [av show];
    }
}

- (IBAction)tappedRegisterButton:(id)sender {
    if (_connectionIdentifier)
        return ;
    
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [[_emailCell textField] resignFirstResponder];
        [[_passwordCell textField] resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:[self view]
                             withText:@"Registering..."
                showActivityIndicator:YES
                             animated:YES];
        [[NAAPIEngine sharedEngine] createAccountWithEmail:email password:password acceptTerms:YES userInfo:self];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Both email and password fields are requierd"];
        [av show];
    }
}

- (IBAction)tappedTermsAndConditions:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cloudapp/policy/blob/master/terms-of-service.md#terms-of-service"]];
}

- (IBAction)tappedForgotPasswordButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://my.cl.ly/reset"]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    
    NAAPIEngine * engine = [NAAPIEngine sharedEngine];
    [engine setEmail:nil];
    [engine setPassword:nil];
    [engine setClearsCookies:NO];

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

- (void)accountCreationSucceeded:(CLAccount *)newAccount connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [self displayMainViewControllerWithAccount:newAccount];
}

- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [self displayMainViewControllerWithAccount:account];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsRevealController
/*----------------------------------------------------------------------------*/
- (void)configureWithRevealController:(PKRevealController *)controller {
    _revealController = controller;
}

/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)displayMainViewControllerWithAccount:(CLAccount *)account {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[NAAPIEngine sharedEngine] setCurrentAccount:account];
    [[NAAPIEngine sharedEngine] setClearsCookies:NO];
    
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    [[NAAPIEngine sharedEngine] setUserWithEmail:email andPassword:password];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAUserLogin" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
