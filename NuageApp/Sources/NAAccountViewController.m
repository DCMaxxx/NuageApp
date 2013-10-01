//
//  NAAccountViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAccountViewController.h"

#import <AFNetworking.h>

#import "NAMenuViewController.h"
#import "NASwitchCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"

#define kAccountDetailsSectionIndex     0
#define kLogoutActionSheetButtonIndex   0


@interface NAAccountViewController () <CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) PKRevealController * revealController;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *customDomainCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *privateUploadCell;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAccountViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NAAPIEngine sharedEngine] addDelegate:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CLAccount * currentAccount = [[NAAPIEngine sharedEngine] currentAccount];
    if ([currentAccount email])
        [[_emailCell detailTextLabel] setText:[currentAccount email]];
    else
        [[_emailCell detailTextLabel] setText:@"Email"];
    
    if ([currentAccount domain])
        [[_customDomainCell detailTextLabel] setText:[[currentAccount domain] absoluteString]];
    else
        [[_customDomainCell detailTextLabel] setText:@"Premium account only"];
    
    [[_privateUploadCell switchView] setOn:([currentAccount uploadsArePrivate]) animated:YES];
    [[_privateUploadCell switchView] addTarget:self action:@selector(changedPrivateUpload:) forControlEvents:UIControlEventValueChanged];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * text = @"";
    if (section == kAccountDetailsSectionIndex) {
        CLAccount * currentAccount = [[NAAPIEngine sharedEngine] currentAccount];
        if ([currentAccount subscriptionExpiresAt]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            text = [NSString stringWithFormat:@"Premium up to %@", [dateFormatter stringFromDate:[currentAccount subscriptionExpiresAt]]];
        } else
            text = @"Standard member";
    }
    return text;
}


/*-----------------------------------n-----------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIActionSheetDelegate
/*----------------------------------------------------------------------------*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == kLogoutActionSheetButtonIndex) {
        [[NAAPIEngine sharedEngine] logout];
        if ([[_revealController leftViewController] isKindOfClass:[NAMenuViewController class]]) {
            NAMenuViewController * mainController = (NAMenuViewController *)[_revealController leftViewController];
            [mainController displayLoginView];
        }
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (void)changedPrivateUpload:(UISwitch *)switchView {
    if (switchView == [_privateUploadCell switchView]) {
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [[NAAPIEngine sharedEngine] changePrivacyOfAccount:[[NAAPIEngine sharedEngine] currentAccount] userInfo:self];
    }
}

- (IBAction)didTapLogoutButton:(id)sender {
    UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"Do you really want to log out ?" delegate:self
                                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
    [as showInView:[self view]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)accountUpdateDidSucceed:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [[NAAPIEngine sharedEngine] setCurrentAccount:account];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
    [[_privateUploadCell switchView] setOn:![[_privateUploadCell switchView] isOn]];

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![[[NAAPIEngine sharedEngine] currentAccount] subscriptionExpiresAt]
        && [identifier isEqualToString:@"ChangeDomainSegue"]) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVPremium];
        [av setMessage:@"You need a premium CloudApp account to setup a custom domain"];
        [av show];
        return NO;
    }
    return YES;
}

- (void)displayMenu {
    [[self revealController] showViewController:[[self revealController] leftViewController]
                                       animated:YES
                                     completion:nil];
}

@end
