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
#import "NANeedsEngine.h"
#import "NASwitchCell.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"

#define kAccountDetailsSectionIndex     0
#define kLogoutActionSheetButtonIndex   0


@interface NAAccountViewController () <CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;
@property (strong, nonatomic) CLAccount * account;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:@"NAUserLogout" object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureWithEngine:_engine];
    [self configureWithRevealController:_revealController];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * text = @"";
    if (section == kAccountDetailsSectionIndex) {
        if ([_account subscriptionExpiresAt]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            text = [NSString stringWithFormat:@"Premium up to %@", [dateFormatter stringFromDate:[_account subscriptionExpiresAt]]];
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
        [_engine logout];
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
        [_engine changePrivacyOfAccount:[_engine currentAccount] userInfo:nil];
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
    [_engine setCurrentAccount:account];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
    [[_privateUploadCell switchView] setOn:![[_privateUploadCell switchView] isOn]];

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
    _account = [_engine currentAccount];

    if ([_account email])
        [[_emailCell detailTextLabel] setText:[_account email]];
    else
        [[_emailCell detailTextLabel] setText:@"Email"];

    if ([_account domain])
        [[_customDomainCell detailTextLabel] setText:[[_account domain] absoluteString]];
    else
        [[_customDomainCell detailTextLabel] setText:@"Premium account only"];

    [[_privateUploadCell switchView] setOn:([_account uploadsArePrivate]) animated:YES];
    [[_privateUploadCell switchView] addTarget:self action:@selector(changedPrivateUpload:) forControlEvents:UIControlEventValueChanged];
    
    [[self tableView] reloadData];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsRevealController
/*----------------------------------------------------------------------------*/
- (void)configureWithRevealController:(PKRevealController *)controller {
    _revealController = controller;
    [[[self navigationController] navigationBar] addGestureRecognizer:[controller revealPanGestureRecognizer]];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem.png"] style:UIBarButtonItemStylePlain
                              target:self action:@selector(displayMenu)];
    [[self navigationItem] setLeftBarButtonItem:item];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![_account subscriptionExpiresAt] && [identifier isEqualToString:@"ChangeDomainSegue"]) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVPremium];
        [av setMessage:@"You need a premium CloudApp account to setup a custom domain"];
        [av show];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController * nextViewController = [segue destinationViewController];
    if ([[nextViewController class] conformsToProtocol:@protocol(NANeedsEngine)])
        [(id<NANeedsEngine>)nextViewController configureWithEngine:_engine];
}

- (void)displayMenu {
    [[self revealController] showViewController:[[self revealController] leftViewController]
                                       animated:YES
                                     completion:nil];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Notification observation
/*----------------------------------------------------------------------------*/
- (void)userDidLogout:(NSNotification *)notification {
    [_engine cancelAllConnections];
}

@end
