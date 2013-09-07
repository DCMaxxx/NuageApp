//
//  NAMainViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAMainViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>

#import "NAAutoUploadViewController.h"
#import "MBProgressHUD+Network.h"
#import "NALoginViewController.h"
#import "NSError+Network.h"
#import "NABonjourClient.h"
#import "NANeedsEngine.h"
#import "UIImage+Data.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kUploadConfirmButtonIndex 1


@interface NAMainViewController () <CLAPIEngineDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NAAPIEngine * engine;

@property (strong, nonatomic) UIViewController * nextViewController;

@property (nonatomic) BOOL isShowingPopup;
@property (nonatomic) BOOL needToShodUploadPopup;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAMainViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _engine = [[NAAPIEngine alloc] initWithDelegate:self];
        _needToShodUploadPopup = NO;
        [self setDelegate:self];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tabBarController:self shouldSelectViewController:[self selectedViewController]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITabBarControllerDelegate
/*----------------------------------------------------------------------------*/
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (![_engine loadUser])
        [self displayLoginView];
    else if (![_engine currentAccount]) {
        [[self navigationItem] setTitle:[viewController title]];
        _nextViewController = viewController;
        [MBProgressHUD showHUDAddedTo:[self view]
                             withText:@"Login in..."
                showActivityIndicator:YES
                             animated:YES];
        [_engine setDelegate:self];
        [_engine getAccountInformationWithUserInfo:nil];
    } else {
        [[self navigationItem] setTitle:[viewController title]];
        if ([[viewController class] conformsToProtocol:@protocol(NANeedsEngine)])
            [(id<NANeedsEngine>)viewController configureWithEngine:_engine];
        return YES;
    }
    return NO;
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

- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
    [_engine setCurrentAccount:account];
    if (_needToShodUploadPopup) {
        _needToShodUploadPopup = NO;
        [self displayUploadConfirmAlertView];
    }
    if (_nextViewController) {
        if ([self tabBarController:self shouldSelectViewController:_nextViewController])
            [self setSelectedViewController:_nextViewController];
        _nextViewController = nil;
    }
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    [MBProgressHUD hideHUDForView:[self view] hideActivityIndicator:YES animated:YES];
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


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)displayLoginView {
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
    NALoginViewController * loginVC = [mainStoryboard instantiateInitialViewController];
    [loginVC configureWithEngine:_engine];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [[nc navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [self presentViewController:nc animated:YES completion:nil];
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
