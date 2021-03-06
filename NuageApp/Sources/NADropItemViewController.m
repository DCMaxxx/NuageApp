//
//  NADropItemViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropItemViewController.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>

#import "NADropItemPickerControllerDelegate.h"
#import "NASettingsViewController.h"
#import "NATextFieldCell.h"
#import "NACopyHandler.h"
#import "NASwitchCell.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kTableViewSectionIndexUploadSettings 0


@interface NADropItemViewController () <CLAPIEngineDelegate, NADropPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet NATextFieldCell *nameCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *privateUploadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemPickerCell;
@property (strong, nonatomic) MBProgressHUD * progressHUD;
@property (strong, nonatomic) NSString * connectionIdentifier;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NADropItemViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[_privateUploadCell switchView] setOn:[[[NAAPIEngine sharedEngine] currentAccount] uploadsArePrivate]];
    
    _progressHUD = [[MBProgressHUD alloc] init];
    [_progressHUD setLabelText:@"Begining upload..."];
    [[self view] addSubview:_progressHUD];
    
    [[_nameCell textField] setPlaceholder:@"Upload name"];
    [[_nameCell textField] setText:[[NAAPIEngine sharedEngine] uniqueName]];
    
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(tappedCancelButton:)];
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:self
                                                                            action:@selector(tappedDoneButton:)];
    [[self navigationItem] setLeftBarButtonItem:left];
    [[self navigationItem] setRightBarButtonItem:right];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"Drop a %@", [_dropPickerController itemDescription]]];
    
    [_dropPickerController setDelegate:self];
    [_dropPickerController cell:_itemPickerCell didLoadWithItem:_item];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NAAPIEngine sharedEngine] addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_connectionIdentifier) {
        [[NAAPIEngine sharedEngine] cancelConnection:_connectionIdentifier];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        [_progressHUD hide:YES];
    }
    [[NAAPIEngine sharedEngine] removeDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * text = nil;
    if (section == kTableViewSectionIndexUploadSettings) {
        text = [NSString stringWithFormat:@"Upload a %@", [_dropPickerController itemDescription]];
    }
    return text;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (void)tappedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedDoneButton:(id)sender {
    [[_nameCell textField] resignFirstResponder];
    if (!_item) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:[_dropPickerController missingItemMessage]];
        [av show];
    } else {
        NSString * name = [[[_nameCell textField] text] stringByAppendingPathExtension:[_dropPickerController itemPathExtenstion]];
        NSDictionary * options = [[NAAPIEngine sharedEngine] uploadDictionaryForPrivacy:[[_privateUploadCell switchView] isOn]];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [_progressHUD show:YES];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        if ([_item isKindOfClass:[NSData class]])
            _connectionIdentifier = [[NAAPIEngine sharedEngine] uploadFileWithName:name fileData:_item options:options userInfo:self];
        else if ([_item isKindOfClass:[NSURL class]])
            _connectionIdentifier = [[NAAPIEngine sharedEngine] bookmarkLinkWithURL:(NSURL *)_item name:name options:options userInfo:self];
    }
}

- (IBAction)tappedPickItemCell:(id)sender {
    [_dropPickerController cell:_itemPickerCell wasTappedOnViewController:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)fileUploadDidProgress:(CGFloat)percentageComplete connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    static NSUInteger lastProgress = NSUIntegerMax;
    NSUInteger newProgress = percentageComplete * 100;
    
    if (lastProgress == NSUIntegerMax)
        [_progressHUD setLabelText:@"Uploading file..."];
    else if (newProgress == 100) {
        [_progressHUD setLabelText:@"Finalizing upload..."];
        [_progressHUD setDetailsLabelText:@"100 %"];
        lastProgress = NSUIntegerMax;
        return ;
    }
    if (newProgress != lastProgress || newProgress == 100) {
        [_progressHUD setDetailsLabelText:[NSString stringWithFormat:@"%zu %%", (unsigned long)newProgress]];
        lastProgress = newProgress;
    }
}

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_progressHUD hide:YES];
    [[NACopyHandler sharedInstance] copyURL:[item URL]];
    [_delegate addedNewItem:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)linkBookmarkDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_progressHUD hide:YES];
    [[NACopyHandler sharedInstance] copyURL:[item URL]];
    [_delegate addedNewItem:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [_progressHUD hide:YES];

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NAItemDropPickerControllerDelegate
/*----------------------------------------------------------------------------*/
- (void)didFinishPickingItem:(id)item {
    _item = item;
}

@end
