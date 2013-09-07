//
//  NAMainViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAMainViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <iAd/ADBannerView.h>
#import <AFNetworking.h>


#import "NAAutoUploadViewController.h"
#import "NANeedsRevealController.h"
#import "MBProgressHUD+Network.h"
#import "NALoginViewController.h"
#import "NSError+Network.h"
#import "NABonjourClient.h"
#import "NANeedsEngine.h"
#import "UIImage+Data.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kUploadConfirmButtonIndex 1


@interface NAMainViewController () <CLAPIEngineDelegate, UIAlertViewDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (strong, nonatomic) UIViewController * nextViewController;
@property (weak, nonatomic) IBOutlet ADBannerView *iAdView;

@property (strong, nonatomic) MBProgressHUD * currentProgressHUD;

@property (nonatomic) BOOL isShowingPopup;
@property (nonatomic) BOOL needToShodUploadPopup;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAMainViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIStoryboard * itemListStoryboard = [UIStoryboard storyboardWithName:@"ItemListStoryboard" bundle:nil];
        UIStoryboard * trashListStoryboard = [UIStoryboard storyboardWithName:@"TrashListStoryboard" bundle:nil];
        UIStoryboard * accountStoryboard = [UIStoryboard storyboardWithName:@"AccountStoryboard" bundle:nil];
        _viewControllers = @[ [accountStoryboard instantiateInitialViewController],
                              [itemListStoryboard instantiateInitialViewController],
                              [trashListStoryboard instantiateInitialViewController]
                             ];
        _engine = [[NAAPIEngine alloc] initWithDelegate:self];
        _needToShodUploadPopup = NO;
    }
    return self;
}

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [_revealController setMinimumWidth:45.0f maximumWidth:310.0f forViewController:self];
    for (UIViewController * vc in _viewControllers)
        [self checkNeedsRevealController:vc];
    [self prepareDisplayViewController:_viewControllers[0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self prepareDisplayViewController:_viewControllers[indexPath.row]];
}

- (void)prepareDisplayViewController:(UIViewController *)viewController {
    if (![_engine loadUser])
        [self displayLoginView];
    else if (![_engine currentAccount]) {
        _nextViewController = viewController;
        
        _currentProgressHUD = [MBProgressHUD showHUDAddedTo:[[_revealController focusedController] view]
                                                   withText:@"Login in..."
                                      showActivityIndicator:YES
                                                   animated:YES];
        [_engine setDelegate:self];
        [_engine getAccountInformationWithUserInfo:nil];
    } else {
        [self displayViewController:viewController];
    }    
}

- (void)displayViewController:(UIViewController *)viewController {
    [self checkNeedsEngine:viewController];
    [_revealController setFrontViewController:viewController];
    [_revealController showViewController:_revealController.frontViewController];
}

- (void)checkNeedsEngine:(UIViewController *)viewController {
    UIViewController * root = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]])
        root = [(UINavigationController *)root viewControllers][0];
    if ([[root class] conformsToProtocol:@protocol(NANeedsEngine)])
        [(id<NANeedsEngine>)root configureWithEngine:_engine];
}

- (void)checkNeedsRevealController:(UIViewController *)viewController {
    UIViewController * root = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]])
        root = [(UINavigationController *)root viewControllers][0];
    if ([[root class] conformsToProtocol:@protocol(NANeedsRevealController)])
        [(id<NANeedsRevealController>)root configureWithRevealController:_revealController];
}

- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[_currentProgressHUD superview] hideActivityIndicator:YES animated:YES];
    [_engine setCurrentAccount:account];
    if (_needToShodUploadPopup) {
        _needToShodUploadPopup = NO;
        [self displayUploadConfirmAlertView];
    }
    if (_nextViewController) {
        [self displayViewController:_nextViewController];
        _nextViewController = nil;
    }
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[_currentProgressHUD superview] hideActivityIndicator:YES animated:YES];
    NAAlertView * av;
    if ([error code] == NSURLErrorUserCancelledAuthentication) { // Loggin in - Bad email or password
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVFailedLogin];
        [av setMessage:@"Please update your password"];
        [self displayLoginView];
    } else if ([error isNetworkError]) { // Network-related error
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
    } else if ([error code] == 1) {
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVPremium];
        [av setMessage:@"You've already uploaded ten drops today. You can switch to a premium account if you want more !"];
    } else {
        NSLog(@"Other error in NAMainViewController : %@", error);
        av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
    }
    [av show];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"loading");
    if ([_iAdView isHidden])
        [_iAdView setHidden:NO];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"unloading !");
    [_iAdView setHidden:YES];
}

- (void)displayLoginView {
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
    UIViewController * loginVC = [mainStoryboard instantiateInitialViewController];
    [self checkNeedsEngine:loginVC];
    [[self revealController] presentViewController:loginVC animated:YES completion:nil];
}


- (void)displayUploadConfirmAlertView {
    if (![_engine currentAccount]) {
        _needToShodUploadPopup = YES;
        _isShowingPopup = NO;
    }
    else if (!_isShowingPopup) {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Auto upload"
                                                      message:@"Do you want to upload last taken picture ?"
                                                     delegate:self
                                            cancelButtonTitle:@"No"
                                            otherButtonTitles:@"Yes", nil];
        [av show];
        _needToShodUploadPopup = NO;
        _isShowingPopup = YES;
    }
}

/*----------------------------------------------------------------------------*/
#pragma mark - UIAletViewDelegate
/*----------------------------------------------------------------------------*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _isShowingPopup = NO;
    if (buttonIndex == kUploadConfirmButtonIndex) {
        [_engine setDelegate:self];
        [self uploadLastTakenPicture];
    }
}

/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)fileUploadDidProgress:(CGFloat)percentageComplete connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    NSLog(@"uploaded %f %% of the file", percentageComplete);
}

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToClipboardKey])
        [[UIPasteboard generalPasteboard] setURL:[item URL]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToMacClipboardKey]) {
        NABonjourClient * client = [NABonjourClient sharedInstance];
        if ([client isReady])
            [[client currentConnection] sendObject:[[item URL] absoluteString] error:nil]; // here, don't care about error
    }
    NAAlertView * av = [[NAAlertView alloc] initWithTitle:@"Last picture uploaded"
                                                  message:@"Cool !"
                                                 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Misc private functions
/*----------------------------------------------------------------------------*/
- (void)uploadLastTakenPicture {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (group) {
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         if ([group numberOfAssets]) {
                                             [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                                 if (asset) {
                                                     ALAssetRepresentation *repr = [asset defaultRepresentation];
                                                     UIImage *img = [UIImage imageWithCGImage:[repr fullScreenImage]];
                                                     [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
                                                     [_engine uploadFileWithName:[[_engine uniqueName] stringByAppendingPathExtension:@"png"]
                                                                        fileData:[img pngData]
                                                                         options:[_engine uploadDictionary]
                                                                        userInfo:nil];
                                                     *stop = YES;
                                                 }
                                             }];
                                         } else {
                                             NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
                                             [av setMessage:@"There's no pictures in camera roll"];
                                             [av show];
                                         }
                                     }
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
                                     [av setMessage:@"Please give NuageApp access to your photos in the Settings application"];
                                     [av show];
                                 }];
}


@end
