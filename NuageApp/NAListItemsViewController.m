//
//  NAListItemsViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 02/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAListItemsViewController.h"

#import <AFNetworkActivityIndicatorManager.h>
#import <UIImageView+AFNetworking.h>

#import "NADropItemPickerController.h"
#import "UIActionSheet+ButtonState.h"
#import "NADropBookmarkController.h"
#import "NADropItemViewController.h"
#import "NADropPictureController.h"
#import "MBProgressHUD+Network.h"
#import "NAItemViewController.h"
#import "NSError+Network.h"
#import "NAIconHandler.h"
#import "NSString+URL.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"

#define kTrashTableViewTag              4242
#define kNumberOfItemsPerPage           15
#define kRestoreItemActionSheetTag      4243
#define kRestoreItemButtonIndex         0
#define kUploadItemActionSheetTag       4244
#define kClipboardContentButtonIndex    0
#define kLinkButtonIndex                1
#define kImageButtonIndex               2


@interface NAListItemsViewController () <CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (nonatomic) BOOL displaysTrash;

@property (strong, nonatomic) NSMutableArray * items;
@property (strong, nonatomic) NSIndexPath * selectedIndexPath;
@property (nonatomic) BOOL isFetchingItems;
@property (nonatomic) NSUInteger currentPage;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAListItemsViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _items = [NSMutableArray array];
        _isFetchingItems = NO;
        _currentPage = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidLogout:)
                                                     name:@"NAUserLogout"
                                                   object:nil];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(triggeredRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    
    _displaysTrash = [[self tableView] tag] == kTrashTableViewTag;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_engine setDelegate:self];

    UINavigationItem *item = [[[self navigationController] navigationBar] items][0];
    UIBarButtonItem * button = nil;
    if (!_displaysTrash) {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                               target:self
                                                               action:@selector(uploadItem:)];
    }
    [item setRightBarButtonItem:button];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"ItemCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CLWebItem * item = _items[indexPath.row];
    
    [[cell imageView] setContentMode:UIViewContentModeScaleAspectFill];
    [[cell imageView] setImage:[NAIconHandler iconWithKind:[item type]]];

    [[cell textLabel] setText:[item name]];
    
    NSString * dateString;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    if (_displaysTrash)
        dateString = [NSString stringWithFormat:@"Deleted on %@", [dateFormatter stringFromDate:[item deletedAt]]];
    else
        dateString = [NSString stringWithFormat:@"Created on %@", [dateFormatter stringFromDate:[item createdAt]]];
    [[cell detailTextLabel] setText:dateString];
    
    return cell;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_displaysTrash) {
        _selectedIndexPath = indexPath;
        UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"Restore item ?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Restore", nil];
        [as setTag:kRestoreItemActionSheetTag];
        [as showFromTabBar:[[self tabBarController] tabBar]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_displaysTrash;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndexPath = indexPath;
        CLWebItem * item = _items[indexPath.row];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [_engine deleteItem:item userInfo:nil];
    }
}



/*----------------------------------------------------------------------------*/
#pragma mark - UIScrollViewDelegate
/*----------------------------------------------------------------------------*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height && !_isFetchingItems)
        [self loadMoreItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIActionSheetDelegate
/*----------------------------------------------------------------------------*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet tag] == kRestoreItemActionSheetTag) {
        if (buttonIndex == kRestoreItemButtonIndex) {
            CLWebItem * item = _items[_selectedIndexPath.row];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            [_engine restoreItem:item userInfo:nil];
        }
    } else if ([actionSheet tag] == kUploadItemActionSheetTag) {
        id<NADropItemPickerController> picker = nil;
        id item = nil;
        if (buttonIndex == kClipboardContentButtonIndex) {
            UIPasteboard * generalPasteboard = [UIPasteboard generalPasteboard];
            if ([generalPasteboard image]) {
                picker = [[NADropPictureController alloc] init];
                item = [generalPasteboard image];
            } else if ([generalPasteboard URL]) {
                picker = [[NADropBookmarkController alloc] init];
                item = [generalPasteboard URL];
            } else if ([[generalPasteboard string] canBeConvertedToURL]) {
                picker = [[NADropBookmarkController alloc] init];
                item = [NSURL URLWithString:[generalPasteboard string]];
            } else
                return ;
        } else if (buttonIndex == kLinkButtonIndex) {
            picker = [[NADropBookmarkController alloc] init];
        } else if (buttonIndex == kImageButtonIndex)
            picker = [[NADropPictureController alloc] init];
        else
            return ;
        [self displayDropItemViewControllerWithPicker:picker andItem:item];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (void)uploadItem:(id)sender {
    UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"What do you want to drop ?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Clipboard content",
                          @"Link",
                          @"Image", nil];
    UIPasteboard * generalPasteboard = [UIPasteboard generalPasteboard];
    if (![[generalPasteboard string] canBeConvertedToURL] && ![generalPasteboard URL] && ![generalPasteboard image])
        [as setButton:kClipboardContentButtonIndex toState:NO];
    [as setTag:kUploadItemActionSheetTag];
    [as showFromTabBar:[[self tabBarController] tabBar]];
}

- (void)triggeredRefreshControl:(id)sender {
    [[self refreshControl] endRefreshing];
    [_engine cancelAllConnections];
    _currentPage = 1;
    _items = [NSMutableArray array];
    _isFetchingItems = NO;
    _selectedIndexPath = nil;
    [[self tableView] reloadData];
    [self loadMoreItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[self tableView] setTableFooterView:nil];

    NAAlertView * av;
    if ([error isNetworkError]) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        NSLog(@"Other error in NAListItemsViewController : %@", error);
    }
    [av show];
    _isFetchingItems = NO;
    _selectedIndexPath = nil;
}

- (void)itemListRetrievalSucceeded:(NSArray *)items connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[self tableView] setTableFooterView:nil];
    
    if ([items count]) {
        _items = [[_items arrayByAddingObjectsFromArray:items] mutableCopy];
        [[self tableView] reloadData];
        ++_currentPage;
    } else
        [[self tableView] setTableFooterView:nil];
    _isFetchingItems = NO;
}

- (void)itemRestorationDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    [_items removeObjectAtIndex:_selectedIndexPath.row];

    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    _selectedIndexPath = nil;
}

- (void)itemDeletionDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    [_items removeObjectAtIndex:_selectedIndexPath.row];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:[[item remoteURL] lastPathComponent]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error)
            NSLog(@"Error %@ while removing file : %@ in NAListItemsViewController", error, path);
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    _selectedIndexPath = nil;
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsEngine
/*----------------------------------------------------------------------------*/
- (void)configureWithEngine:(NAAPIEngine *)engine {
    _engine = engine;
    [_engine setDelegate:self];
    if (![_items count])
        [self loadMoreItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NAItemUpdate
/*----------------------------------------------------------------------------*/
- (void)item:(CLWebItem *)item wasUpdatedToItem:(CLWebItem *)updatedItem {
    NSUInteger itemIdx = [_items indexOfObject:item];
    if (itemIdx != NSNotFound) {
        [_items replaceObjectAtIndex:itemIdx withObject:updatedItem];
        [[self tableView] reloadData];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ItemViewSegue"]) {
        NSIndexPath * selectedIndexPath = [[self tableView] indexPathsForSelectedRows][0];
        NAItemViewController * itemViewController = [segue destinationViewController];
        [itemViewController configureWithItem:_items[selectedIndexPath.row]];
        [itemViewController configureWithEngine:_engine];
        [itemViewController setDelegate:self];
    }
}

- (void)displayDropItemViewControllerWithPicker:(id<NADropItemPickerController>)picker andItem:(id)item {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UploadStoryboard" bundle:nil];
    NADropItemViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"NADropItemViewController"];
    [vc setDropPickerController:picker];
    [vc configureWithEngine:_engine];
    [vc setItem:item];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Notification observation
/*----------------------------------------------------------------------------*/
- (void)userDidLogout:(NSNotification *)notification {
    [_engine cancelAllConnections];
    _currentPage = 1;
    _items = [NSMutableArray array];
    _isFetchingItems = NO;
    _selectedIndexPath = nil;
    [[self tableView] reloadData];
    NSLog(@"Called");
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)loadMoreItems {
    if (!_isFetchingItems) {
        if (![_items count]) {
            [MBProgressHUD showHUDAddedTo:[self view]
                                 withText:@"Loading drops..."
                    showActivityIndicator:YES
                                 animated:YES];
        } else {
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            UIActivityIndicatorView * view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [view setFrame:CGRectMake(0, 0, 42, 42)];
            [view startAnimating];
            [[self tableView] setTableFooterView:view];
            if ([_items count] >= kNumberOfItemsPerPage) {
                CGPoint contentOffset = [[self tableView] contentOffset];
                contentOffset.y += CGRectGetHeight([view frame]);
                [[self tableView] setContentOffset:contentOffset animated:YES];
            }
        }
        if (_displaysTrash)
            [_engine getItemListStartingAtPage:_currentPage ofType:CLWebItemTypeNone itemsPerPage:kNumberOfItemsPerPage showOnlyItemsInTrash:YES userInfo:nil];
        else
            [_engine getItemListStartingAtPage:_currentPage itemsPerPage:kNumberOfItemsPerPage userInfo:nil];
        _isFetchingItems = YES;
    }
}

@end
