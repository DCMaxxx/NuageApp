//
//  NAChangeDomainViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 30/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAChangeDomainViewController.h"

#import "MBProgressHUD+Network.h"
#import "NSError+Network.h"
#import "NATextFieldCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"


@interface NAChangeDomainViewController () <CLAPIEngineDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (weak, nonatomic) IBOutlet NATextFieldCell *domainCell;
@property (weak, nonatomic) IBOutlet NATextFieldCell *domainHomeCell;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAChangeDomainViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [[_domainCell textField] setPlaceholder:@"Custom domain"];
    [[_domainHomeCell textField] setPlaceholder:@"Home page (optional)"];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedSaveButton:(id)sender {
    NSString * domain = [[_domainCell textField] text];
    NSString * domainHome = [[_domainHomeCell textField] text];
    if ([domain length]) {
        [_engine updateCustomDomain:domain customDomainHome:([domainHome length] ? domainHome : nil) userInfo:nil];
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
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [_engine setCurrentAccount:account];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    
    NAAlertView * av;
    if ([error isNetworkError]) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else if ([error code] == NSURLErrorUnknown && [[error userInfo][@"statusCode"] isEqual:@(204)]) { // Need paid plan. I guess.
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVPremium];
        [av setMessage:@"A premium account is needed to setup a custom domain"];
    }
    else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error on NAChangeDomainViewController : %@", error);
    }
    [av show];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];

    CLAccount * account = [_engine currentAccount];
    [[_domainCell textField] setText:[[account domain] absoluteString]];
    [[_domainHomeCell textField] setText:[[account domainHomePage] absoluteString]];
    [[self tableView] reloadData];
}

@end
