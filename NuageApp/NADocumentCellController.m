//
//  NADocumentCellController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADocumentCellController.h"

#import <AFNetworking.h>
#import <CLWebItem.h>

#import "MBProgressHUD+Network.h"
#import "NAIconHandler.h"
#import "NAAlertView.h"


@interface NADocumentCellController ()

@property (strong, nonatomic) NSString * savedFilePath;
@property (strong, nonatomic) UIDocumentInteractionController * dc;
@property (nonatomic) BOOL isDownloadingFile;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NADocumentCellController


/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewItemCellController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    _isDownloadingFile = NO;
    [[cell contentView] addSubview:[[UIImageView alloc] initWithImage:[NAIconHandler iconWithKind:[webItem type]]]];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    if (_isDownloadingFile)
        return ;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:[[webItem remoteURL] lastPathComponent]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _savedFilePath = path;
        [self openInOtherAppWithView:cell.contentView];
    } else {
        _isDownloadingFile = YES;
        [MBProgressHUD showHUDAddedTo:[cell contentView] withText:@"Downloading file..." showActivityIndicator:NO animated:YES];
        NSURL * baseURL = [[NSURL URLWithString:@"/" relativeToURL:[webItem remoteURL]] absoluteURL];
        AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        NSURLRequest * request = [client requestWithMethod:@"GET" path:[[webItem remoteURL] path] parameters:nil];
        AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:path append:NO]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:[cell contentView] animated:YES];
            _isDownloadingFile = NO;
            _savedFilePath = path;
            [self openInOtherAppWithView:cell.contentView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:[cell contentView] animated:YES];
            _isDownloadingFile = NO;
            NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:nil];
            [av show];
        }];
        [operation start];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)openInOtherAppWithView:(UIView *)view {
    NSURL * url = [NSURL fileURLWithPath:_savedFilePath];
    _dc = [UIDocumentInteractionController interactionControllerWithURL:url];
    if (![_dc presentOpenInMenuFromRect:CGRectZero inView:view animated:YES]) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        [av setMessage:@"You have no application that handles this kind of file."];
        [av show];
    }
}

@end
