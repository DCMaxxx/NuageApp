//
//  NALoginViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 28/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NALoginViewController.h"

#import "MBProgressHUD+Network.h"
#import "NSError+Network.h"
#import "NATextFieldCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NALoginViewController () <CLAPIEngineDelegate>

@property (weak, nonatomic) IBOutlet NATextFieldCell *emailCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *passwordCell;

@property (strong, nonatomic) NAAPIEngine * engine;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NALoginViewController

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
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITextFieldDelegate
/*----------------------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}


/*----------------------------------------------------------------------------*/
#pragma mark - User actions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedLoginButton:(id)sender {
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [MBProgressHUD showHUDAddedTo:[self view]
                             withText:@"Loggin in..."
                showActivityIndicator:YES
                             animated:YES];
        [_engine setClearsCookies:YES];
        [_engine setEmail:email];
        [_engine setPassword:password];
        [_engine getAccountInformationWithUserInfo:nil];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Both email and password fields are requierd"];
        [av show];
    }
}

- (IBAction)tappedRegisterButton:(id)sender {
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    if ([email length] && [password length]) {
        [MBProgressHUD showHUDAddedTo:[self view]
                             withText:@"Registering..."
                showActivityIndicator:YES
                             animated:YES];
        [_engine createAccountWithEmail:email password:password acceptTerms:YES userInfo:nil];
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
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    
    [_engine setEmail:nil];
    [_engine setPassword:nil];
    [_engine setClearsCookies:NO];

    NAAlertView * av;
    if ([error code] == NSURLErrorUnknown && [error userInfo][NSLocalizedRecoverySuggestionErrorKey]) { // Registering - Invalid email
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedRegistering];
        [av setMessage:@"Please enter a valid email address"];
    } else if ([error code] == NSURLErrorUnknown && [[error userInfo][@"statusCode"] isEqual:@(406)]) { // Registering - Email already in use
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedRegistering];
        [av setMessage:@"This email address is already in use"];
    } else if ([error code] == NSURLErrorUserCancelledAuthentication) { // Loggin in - Bad email or password
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedLogin];
    } else if ([error code] == NSURLErrorUnknown && [[error userInfo][@"statusCode"] isEqual:@(409)]) { // Loggin in - Unactivated account (Never got it though)
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVUnactivatedAccount];
    } else if ([error isNetworkError]) { // Network-related error
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error in NALoginViewController : %@", error);
    }
    [av show];
}

- (void)accountCreationSucceeded:(CLAccount *)newAccount connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];

    [_engine setCurrentAccount:newAccount];
    [_engine setClearsCookies:NO];
    [self displayMainViewControllerWithTabIndex:1];
}

- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];

    [_engine setCurrentAccount:account];
    [_engine setClearsCookies:NO];
    [self displayMainViewControllerWithTabIndex:1];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
    [[_emailCell textField] setText:[_engine email]];
    [[self tableView] reloadData];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)displayMainViewControllerWithTabIndex:(NSUInteger)tabIndex {
    NSString * email = [[_emailCell textField] text];
    NSString * password = [[_passwordCell textField] text];
    [_engine setUserWithEmail:email andPassword:password];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
