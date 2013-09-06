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
#import "NAAutoUploadViewController.h"
#import "NSError+Network.h"
#import "NATextFieldCell.h"
#import "NASwitchCell.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kUploadSettingsSectionIndex 0


@interface NADropItemViewController () <CLAPIEngineDelegate, NADropPickerControllerDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (weak, nonatomic) IBOutlet NATextFieldCell *nameCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *privateUploadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemPickerCell;
@property (strong, nonatomic) MBProgressHUD * progressHUD;

@property (strong, nonatomic) id fileData;

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
    
    if (_engine)
        [[_privateUploadCell switchView] setOn:[[_engine currentAccount] uploadsArePrivate]];
    
    _progressHUD = [[MBProgressHUD alloc] init];
    [_progressHUD setLabelText:@"Begining upload..."];
    [[self view] addSubview:_progressHUD];
    
    [[_nameCell textField] setPlaceholder:@"Upload name"];
    [[_nameCell textField] setText:[_engine uniqueName]];
    
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(tappedCancelButton:)];
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:self
                                                                            action:@selector(tappedDoneButton:)];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [[self navigationItem] setLeftBarButtonItem:left];
    [[self navigationItem] setRightBarButtonItem:right];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"Drop a %@", [_dropPickerController itemDescription]]];
    
    [_dropPickerController setDelegate:self];
    [_dropPickerController cell:_itemPickerCell didLoadWithItem:_item];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * text = nil;
    if (section == kUploadSettingsSectionIndex) {
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
    if (!_fileData) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:[_dropPickerController missingItemMessage]];
        [av show];
    } else {
        NSString * name = [[[_nameCell textField] text] stringByAppendingPathExtension:[_dropPickerController itemPathExtenstion]];
        NSDictionary * options = [_engine uploadDictionaryForPrivacy:[[_privateUploadCell switchView] isOn]];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [_progressHUD show:YES];
        if ([_fileData isKindOfClass:[NSData class]])
            [_engine uploadFileWithName:name fileData:_fileData options:options userInfo:nil];
        else if ([_fileData isKindOfClass:[NSURL class]])
            [_engine bookmarkLinkWithURL:(NSURL *)_fileData name:name options:options userInfo:nil];
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
        lastProgress = NSUIntegerMax;
        return ;
    }
    if (newProgress != lastProgress) {
        [_progressHUD setDetailsLabelText:[NSString stringWithFormat:@"%zu %%", (unsigned long)newProgress]];
        lastProgress = newProgress;
    }
}

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_progressHUD hide:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToClipboardKey])
        [[UIPasteboard generalPasteboard] setURL:[item URL]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)linkBookmarkDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_progressHUD hide:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToClipboardKey])
        [[UIPasteboard generalPasteboard] setURL:[item URL]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_progressHUD hide:YES];

    NAAlertView * av;
    if ([error isNetworkError]) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else if ([error code] == 1) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVPremium];
        [av setMessage:@"You've already uploaded ten drops today. You can switch to a premium account if you want more !"];
    }
    else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error on NDropItemViewController : %@", error);
    }
    [av show];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NAItemDropPickerControllerDelegate
/*----------------------------------------------------------------------------*/
- (void)didFinishPickingItem:(id)item {
    _fileData = item;
}

@end
