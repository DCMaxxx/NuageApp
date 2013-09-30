//
//  NAChangeDomainViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 30/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAChangeDomainViewController.h"

#import "MBProgressHUD+Network.h"
#import "NATextFieldCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NAChangeDomainViewController () <CLAPIEngineDelegate>

@property (weak, nonatomic) IBOutlet NATextFieldCell *domainCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *domainHomeCell;
@property (strong, nonatomic) NSString * connectionIdentifier;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangeDomainViewController

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
    [[_domainCell textField] setPlaceholder:@"Custom domain"];
    [[_domainCell textField] setKeyboardType:UIKeyboardTypeURL];
    [[_domainCell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[_domainCell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
    [[_domainHomeCell textField] setPlaceholder:@"Home page (optional)"];
    [[_domainCell textField] setKeyboardType:UIKeyboardTypeURL];
    [[_domainCell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[_domainCell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLAccount * account = [[NAAPIEngine sharedEngine] currentAccount];
    [[_domainCell textField] setText:[[account domain] absoluteString]];
    [[_domainHomeCell textField] setText:[[account domainHomePage] absoluteString]];
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
    NSString * domain = [[_domainCell textField] text];
    NSString * domainHome = [[_domainHomeCell textField] text];
    if ([domain length]) {
        [[_domainCell textField] resignFirstResponder];
        [[_domainHomeCell textField] resignFirstResponder];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        _connectionIdentifier = [[NAAPIEngine sharedEngine] updateCustomDomain:domain
                                                              customDomainHome:([domainHome length] ? domainHome : nil)
                                                                      userInfo:self];
        [MBProgressHUD showHUDAddedTo:[self view] withText:@"Updating account..." showActivityIndicator:YES animated:YES];
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"Custom domain field is required"];
        [av show];
    }
}

- (IBAction)tappedMoreInfoButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://support.getcloudapp.com/customer/portal/articles/270990-custom-domains"]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)accountUpdateDidSucceed:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[NAAPIEngine sharedEngine] setCurrentAccount:account];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

@end
