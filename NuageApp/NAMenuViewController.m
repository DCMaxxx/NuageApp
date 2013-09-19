//
//  NAMainViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAMenuViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>

#import "NASettingsViewController.h"
#import "NANeedsRevealController.h"
#import "MBProgressHUD+Network.h"
#import "NALoginViewController.h"
#import "NACopyHandler.h"
#import "UIImage+Data.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kAlertViewButtonIndexUpload 1


@interface NAMenuViewController () <CLAPIEngineDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIViewController * nextViewController;
@property (nonatomic) BOOL isShowingPopup;
@property (nonatomic) BOOL needToShodUploadPopup;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAMenuViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _viewControllers = @[ [[UIStoryboard storyboardWithName:@"ItemListStoryboard" bundle:nil] instantiateInitialViewController],
                              [[UIStoryboard storyboardWithName:@"TrashListStoryboard" bundle:nil] instantiateInitialViewController],
                              [[UIStoryboard storyboardWithName:@"AccountStoryboard" bundle:nil] instantiateInitialViewController],
                              [[UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil] instantiateInitialViewController]
                             ];
        [[NAAPIEngine sharedEngine] addDelegate:self];
        _needToShodUploadPopup = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(displayUploadConfirmAlertView)
                                                     name:@"NAApplicationWillEnterForeground"
                                                   object:nil];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [_revealController setMinimumWidth:200.0f maximumWidth:310.0f forViewController:self];
    for (UIViewController * vc in _viewControllers)
        [self checkNeedsRevealController:vc];
    [self prepareDisplayViewController:_viewControllers[0]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self prepareDisplayViewController:_viewControllers[indexPath.row]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIAletViewDelegate
/*----------------------------------------------------------------------------*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _isShowingPopup = NO;
    if (buttonIndex == kAlertViewButtonIndexUpload)
        [self uploadLastTakenPicture];
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[[_revealController frontViewController] view] hideActivityIndicator:YES animated:YES];
    [[NAAPIEngine sharedEngine] setCurrentAccount:account];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAUserLogin" object:nil];
    if (_needToShodUploadPopup) {
        _needToShodUploadPopup = NO;
        [self displayUploadConfirmAlertView];
    }
    if (_nextViewController) {
        [self displayViewController:_nextViewController];
        _nextViewController = nil;
    }
}

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [[NACopyHandler sharedInstance] copyURL:[item URL]];
    NAAlertView * av = [[NAAlertView alloc] initWithTitle:@"Picture uploaded"
                                                  message:@"Link has been copied according to your preferences"
                                                 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[[_revealController frontViewController] view] hideActivityIndicator:YES animated:YES];
    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:userInfo];
    [av show];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)prepareDisplayViewController:(UIViewController *)viewController {
    NAAPIEngine * engine = [NAAPIEngine sharedEngine];
    if (![engine loadUser])
        [self displayLoginView];
    else if (![engine currentAccount]) {
        _nextViewController = viewController;
        [MBProgressHUD showHUDAddedTo:[[_revealController frontViewController] view] withText:@"Login in..."
                                      showActivityIndicator:YES animated:YES];
        [engine getAccountInformationWithUserInfo:self];
    } else {
        [self displayViewController:viewController];
    }
}

- (void)displayViewController:(UIViewController *)viewController {
    [_revealController setFrontViewController:viewController];
    [_revealController showViewController:_revealController.frontViewController];
}

- (void)displayLoginView {
    UIViewController * loginVC = [[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil] instantiateInitialViewController];
    [self checkNeedsRevealController:loginVC];
    [[self revealController] presentViewController:loginVC animated:YES completion:nil];
}

- (void)displayUploadConfirmAlertView {
    if (![[NAAPIEngine sharedEngine] currentAccount]) {
        _needToShodUploadPopup = YES;
        _isShowingPopup = NO;
    } else if (!_isShowingPopup) {
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
                                                     NAAPIEngine * engine = [NAAPIEngine sharedEngine];
                                                     [engine uploadFileWithName:[[engine uniqueName] stringByAppendingPathExtension:@"png"]
                                                                        fileData:[img pngData]
                                                                         options:[engine uploadDictionary]
                                                                        userInfo:self];
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

- (void)checkNeedsRevealController:(UIViewController *)viewController {
    UIViewController * root = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]])
        root = [(UINavigationController *)root viewControllers][0];
    if ([[root class] conformsToProtocol:@protocol(NANeedsRevealController)])
        [(id<NANeedsRevealController>)root configureWithRevealController:_revealController];
}

@end
