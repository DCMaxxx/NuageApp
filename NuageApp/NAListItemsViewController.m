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
#import "NAIconHandler.h"
#import "NSString+URL.h"
#import "NAAlertView.h"
#import "NAAPIEngine.h"

#define kTrashTableViewTag              4242
#define kNumberOfItemsPerPage           15
#define kAlertViewButtonIndexRestore    0
#define kAlertViewButtonIndexClipboard  0
#define kAlertViewButtonIndexLink       1
#define kAlertViewButtonIndexImage      2

typedef enum { NAFetchingMoreItems, NARefreshingItems, NANotFetchingItems } NAFetchingItemType;


@interface NAListItemsViewController () <CLAPIEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) PKRevealController * revealController;
@property (nonatomic) BOOL displaysTrash;
@property (strong, nonatomic) NSMutableArray * items;
@property (strong, nonatomic) NSIndexPath * selectedIndexPath;
@property (nonatomic) NAFetchingItemType fetchingItemType;
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
        _fetchingItemType = NANotFetchingItems;
        _currentPage = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:@"NAUserLogout" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:@"NAUserLogin" object:nil];
        [[NAAPIEngine sharedEngine] addDelegate:self];
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
    [self configureWithRevealController:_revealController];
    
    if (![_items count])
        [self loadMoreItems];
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
        UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"Restore item ?" delegate:self
                                                cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                otherButtonTitles:@"Restore", nil];
        [as showInView:[self view]];
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
        [[NAAPIEngine sharedEngine] deleteItem:item userInfo:self];
    }
}



/*----------------------------------------------------------------------------*/
#pragma mark - UIScrollViewDelegate
/*----------------------------------------------------------------------------*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height
        && _fetchingItemType == NANotFetchingItems
        && [_items count] >= kNumberOfItemsPerPage)
        [self loadMoreItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIActionSheetDelegate
/*----------------------------------------------------------------------------*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_displaysTrash) {
        if (buttonIndex == kAlertViewButtonIndexRestore) {
            CLWebItem * item = _items[_selectedIndexPath.row];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            [[NAAPIEngine sharedEngine] restoreItem:item userInfo:self];
        }
    } else {
        id<NADropItemPickerController> picker = nil;
        id item = nil;
        if (buttonIndex == kAlertViewButtonIndexClipboard) {
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
        } else if (buttonIndex == kAlertViewButtonIndexLink) {
            picker = [[NADropBookmarkController alloc] init];
        } else if (buttonIndex == kAlertViewButtonIndexImage)
            picker = [[NADropPictureController alloc] init];
        else
            return ;
        [self displayDropItemViewControllerWithPicker:picker andItem:item];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)uploadItem:(id)sender {
    UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"What do you want to drop ?" delegate:self
                                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                            otherButtonTitles:@"Clipboard content", @"Link", @"Image", nil];
    UIPasteboard * generalPasteboard = [UIPasteboard generalPasteboard];
    if (![[generalPasteboard string] canBeConvertedToURL] && ![generalPasteboard URL] && ![generalPasteboard image])
        [as setButton:kAlertViewButtonIndexClipboard toState:NO];
    [as showInView:[self view]];
}

- (void)triggeredRefreshControl:(id)sender {
    [self reloadItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[self tableView] setTableFooterView:nil];

    if (_fetchingItemType == NARefreshingItems)
        [[self refreshControl] endRefreshing];
    _fetchingItemType = NANotFetchingItems;
    _selectedIndexPath = nil;

    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

- (void)itemListRetrievalSucceeded:(NSArray *)items connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [[self tableView] setTableFooterView:nil];
    
    NSMutableArray * indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [items count]; ++i) {
        NSIndexPath * indexPath = nil;
        if (_fetchingItemType == NAFetchingMoreItems) {
            [_items addObject:items[i]];
            indexPath = [NSIndexPath indexPathForRow:[_items count]-1 inSection:0];
        } else if (_fetchingItemType == NARefreshingItems) {
            if (i >= [_items count] || ![[items[i] href] isEqual:[_items[i] href]]) {
                [_items insertObject:items[i] atIndex:i];
                indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
        if (indexPath)
            [indexPaths addObject:indexPath];
    }
    if ([indexPaths count]) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    if (_fetchingItemType == NARefreshingItems)
        [[self refreshControl] endRefreshing];
    _fetchingItemType = NANotFetchingItems;
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
    
    if ([[[item remoteURL] lastPathComponent] length]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths[0] stringByAppendingPathComponent:[[item remoteURL] lastPathComponent]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error)
                NSLog(@"Error %@ while removing file : %@ in NAListItemsViewController", error, path);
        }
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    _selectedIndexPath = nil;
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
#pragma mark - NAItemUpdate
/*----------------------------------------------------------------------------*/
- (void)item:(CLWebItem *)item wasUpdatedToItem:(CLWebItem *)updatedItem {
    NSUInteger itemIdx = [_items indexOfObject:item];
    if (itemIdx != NSNotFound) {
        [_items replaceObjectAtIndex:itemIdx withObject:updatedItem];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:itemIdx inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)addedNewItem:(CLWebItem *)item {
    [_items insertObject:item atIndex:0];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ItemViewSegue"]) {
        NSIndexPath * selectedIndexPath = [[self tableView] indexPathsForSelectedRows][0];
        NAItemViewController * itemViewController = [segue destinationViewController];
        [itemViewController configureWithItem:_items[selectedIndexPath.row]];
        [itemViewController setDelegate:self];
    }
}

- (void)displayDropItemViewControllerWithPicker:(id<NADropItemPickerController>)picker andItem:(id)item {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ItemListStoryboard" bundle:nil];
    NADropItemViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"NADropItemViewController"];
    [vc setDropPickerController:picker];
    [vc setItem:item];
    [vc setDelegate:self];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)displayMenu {
    [[self revealController] showViewController:[[self revealController] leftViewController] animated:YES completion:nil];
}



/*----------------------------------------------------------------------------*/
#pragma mark - Notification observation
/*----------------------------------------------------------------------------*/
- (void)userDidLogout:(NSNotification *)notification {
    _currentPage = 1;
    _items = [NSMutableArray array];
    _fetchingItemType = NANotFetchingItems;
    _selectedIndexPath = nil;
    [[self tableView] reloadData];
}

- (void)userDidLogin:(NSNotification *)notification {
    if (![_items count] && [_revealController focusedController] == [self navigationController])
        [self loadMoreItems];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)loadMoreItems {
    if (_fetchingItemType == NANotFetchingItems && [[NAAPIEngine sharedEngine] currentAccount]) {
        if (![_items count]) {
            [MBProgressHUD showHUDAddedTo:[self view] withText:@"Loading drops..." showActivityIndicator:YES animated:YES];
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
            [[NAAPIEngine sharedEngine] getItemListStartingAtPage:_currentPage ofType:CLWebItemTypeNone
                                                     itemsPerPage:kNumberOfItemsPerPage showOnlyItemsInTrash:YES userInfo:self];
        else
            [[NAAPIEngine sharedEngine] getItemListStartingAtPage:_currentPage itemsPerPage:kNumberOfItemsPerPage userInfo:self];
        _fetchingItemType = NAFetchingMoreItems;
    }
}

- (void)reloadItems {
    if (_fetchingItemType == NANotFetchingItems && [[NAAPIEngine sharedEngine] currentAccount]) {
        if (_displaysTrash)
            [[NAAPIEngine sharedEngine] getItemListStartingAtPage:1 ofType:CLWebItemTypeNone
                                                     itemsPerPage:kNumberOfItemsPerPage showOnlyItemsInTrash:YES userInfo:self];
        else
            [[NAAPIEngine sharedEngine] getItemListStartingAtPage:1 itemsPerPage:kNumberOfItemsPerPage userInfo:self];
        _fetchingItemType = NARefreshingItems;
    }
}

@end
