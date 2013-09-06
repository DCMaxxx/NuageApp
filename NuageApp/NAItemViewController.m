//
//  NAItemViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 01/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAItemViewController.h"

#import <AFNetworkActivityIndicatorManager.h>

#import "NAPreviewItemCellController.h"
#import "NAAudioVideoCellController.h"
#import "NADocumentCellController.h"
#import "NAImageCellController.h"
#import "NATextCellController.h"
#import "NAWebCellController.h"
#import "NACopyToMacActivity.h"
#import "NSError+Network.h"
#import "NAIconHandler.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kInformationsSectionIndex   1
#define kUpdatingNameUserInfo       @"updatingName"
#define kUpdatingPrivateUserInfo    @"updatingPrivate"


@interface NAItemViewController () <NATextFieldCellDelegate, CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (strong, nonatomic) id<NAPreviewItemCellController> previewCellController;

@property (nonatomic) BOOL isUpdatingName;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAItemViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _isUpdatingName = NO;
    }
    return self;
}

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];

    [_itemNameCell setCellDelegate:self];
    [[_itemNameCell textField] setText:[_webItem name]];
    [[_itemNameCell textField] setBackgroundColor:[UIColor clearColor]];
    [_itemNameCell setBackgroundColor:[UIColor clearColor]];
    
    [[_itemLinkCell textLabel] setText:[[_webItem URL] absoluteString]];
    
    [[_itemPrivateCell switchView] setOn:[_webItem isPrivate]];
    [[_itemPrivateCell switchView] addTarget:self action:@selector(changedPrivacy:) forControlEvents:UIControlEventValueChanged];

    [_previewCellController cell:_itemPreviewCell didLoadWithWebItem:_webItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_engine setDelegate:self];
    if ([_previewCellController respondsToSelector:@selector(cell:willAppearWithWebItem:)])
        [_previewCellController cell:_itemPreviewCell willAppearWithWebItem:_webItem];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString * text = nil;
    if (section == kInformationsSectionIndex) {
        text = [NSString stringWithFormat:@"%d views", [_webItem viewCount]];
    }
    return text;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == _itemPreviewCell) {
        [_previewCellController cell:cell wasTappedOnViewController:self withWebItem:_webItem];
    } else if (cell == _itemLinkCell) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[_webItem.URL.absoluteString]
                                                        applicationActivities:@[[[NACopyToMacActivity alloc] init]]];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - NATextFieldCellDelegate
/*----------------------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![[textField text] length]) {
        [textField setText:[_webItem name]];
    } else if (![[textField text] isEqualToString:[_webItem name]]) {
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [_engine changeNameOfItem:_webItem toName:[textField text] userInfo:kUpdatingNameUserInfo];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return !_isUpdatingName;
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    NAAlertView * av;
    if ([error isNetworkError]) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error in NAItemViewController : %@", error);
    }
    [av show];
    
    if ([userInfo isEqual: kUpdatingNameUserInfo]) {
        [[_itemNameCell textField] setText:[_webItem name]];
    } else if ([userInfo isEqual:kUpdatingPrivateUserInfo]) {
        [[_itemPrivateCell switchView] setOn:[_webItem isPrivate]];
    }
}

- (void)itemUpdateDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_delegate item:_webItem wasUpdatedToItem:item];
    _webItem = item;
    
    if ([userInfo isEqual: kUpdatingNameUserInfo]) {
        [[self navigationItem] setTitle:[_webItem name]];
    } else if ([userInfo isEqual:kUpdatingPrivateUserInfo])
        [[_itemLinkCell textLabel] setText:[[_webItem URL] absoluteString]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (void)changedPrivacy:(UISwitch *)switchView {
    if (switchView == [_itemPrivateCell switchView]) {
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [_engine changePrivacyOfItem:_webItem toPrivate:[switchView isOn] userInfo:kUpdatingPrivateUserInfo];
    }
}

/*----------------------------------------------------------------------------*/
#pragma mark - Misc public methods
/*----------------------------------------------------------------------------*/
- (void)configureWithItem:(CLWebItem *)item {
    _webItem = item;
    [self setTitle:[item name]];
    
    switch ([item type]) {
        case CLWebItemTypeImage:
            _previewCellController = [[NAImageCellController alloc] init];
            break;
        case CLWebItemTypeBookmark:
            _previewCellController = [[NAWebCellController alloc] init];
            break;
        case CLWebItemTypeText:
            _previewCellController = [[NATextCellController alloc] init];
            break;
        case CLWebItemTypeAudio:
        case CLWebItemTypeVideo:
            _previewCellController = [[NAAudioVideoCellController alloc] init];
            break;
        case CLWebItemTypeArchive:
        case CLWebItemTypeUnknown:
        default:
            _previewCellController = [[NADocumentCellController alloc] init];
            break;
    }
}

@end
