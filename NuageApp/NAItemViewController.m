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
#import "NAIconHandler.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kTableViewSectionIndexViewInformations   1

typedef enum { NAUpdatingItemName, NAUpdatingItemPrivacy, NAUpdatingItemNone } NAUpdatingItemType;


@interface NAItemViewController () <NATextFieldCellDelegate, CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) id<NAPreviewItemCellController> previewCellController;
@property (nonatomic) NAUpdatingItemType currentUpdate;
@property (strong, nonatomic) NSString * connectionIdentifier;

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
        _currentUpdate = NAUpdatingItemNone;
        [[NAAPIEngine sharedEngine] addDelegate:self];
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

    if ([_previewCellController respondsToSelector:@selector(cell:willAppearWithWebItem:)])
        [_previewCellController cell:_itemPreviewCell willAppearWithWebItem:_webItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_connectionIdentifier) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        [[NAAPIEngine sharedEngine] cancelConnection:_connectionIdentifier];
    }
    [[NAAPIEngine sharedEngine] removeDelegate:self];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kTableViewSectionIndexViewInformations) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        NSString * footerString;
        if ([_webItem viewCount] == 0)
            footerString = [NSString stringWithFormat:@"No views since %@",
                            [dateFormatter stringFromDate:[_webItem createdAt]]];
        else if ([_webItem viewCount] == 1)
            footerString = [NSString stringWithFormat:@"One view since %@",
                            [dateFormatter stringFromDate:[_webItem createdAt]]];
        else
            footerString = [NSString stringWithFormat:@"%@ views since %@", @([_webItem viewCount]),
                            [dateFormatter stringFromDate:[_webItem createdAt]]];
        return footerString;
    }
    return nil;
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
        _currentUpdate = NAUpdatingItemName;
        _connectionIdentifier = [[NAAPIEngine sharedEngine] changeNameOfItem:_webItem
                                                                      toName:[textField text]
                                                                    userInfo:self];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return _currentUpdate != NAUpdatingItemName;
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    if (_currentUpdate == NAUpdatingItemName)
        [[_itemNameCell textField] setText:[_webItem name]];
    else if (_currentUpdate == NAUpdatingItemPrivacy)
        [[_itemPrivateCell switchView] setOn:[_webItem isPrivate]];

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

- (void)itemUpdateDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    _connectionIdentifier = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_delegate item:_webItem wasUpdatedToItem:item];
    _webItem = item;
    
    if (_currentUpdate == NAUpdatingItemName)
        [[self navigationItem] setTitle:[_webItem name]];
    else if (_currentUpdate == NAUpdatingItemPrivacy)
        [[_itemLinkCell textLabel] setText:[[_webItem URL] absoluteString]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (void)changedPrivacy:(UISwitch *)switchView {
    if (switchView == [_itemPrivateCell switchView]) {
        [[_itemNameCell textField] resignFirstResponder];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        _currentUpdate = NAUpdatingItemPrivacy;
        _connectionIdentifier = [[NAAPIEngine sharedEngine] changePrivacyOfItem:_webItem
                                                                      toPrivate:[switchView isOn]
                                                                       userInfo:self];
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
