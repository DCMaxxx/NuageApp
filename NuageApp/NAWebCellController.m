//
//  NAWebCellController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAWebCellController.h"

#import <CLWebItem.h>

#import "NABookmarkDisplayViewController.h"
#import "MBProgressHUD+Network.h"
#import "NAAlertView.h"


@interface NAWebCellController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView * webView;
@property (nonatomic) BOOL endedLoading;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAWebCellController

/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewItemCellViewController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    _endedLoading = NO;
    NSURLRequest * request = [NSURLRequest requestWithURL:[webItem remoteURL]];
    _webView = [[UIWebView alloc] init];
    [self configureWebViewInCell:cell];
    [_webView loadRequest:request];
    [MBProgressHUD showHUDAddedTo:_webView withText:@"Loading website..." showActivityIndicator:YES animated:YES];
    [[cell contentView] addSubview:_webView];
}

- (void)cell:(UITableViewCell *)cell willAppearWithWebItem:(CLWebItem *)webItem {
    [self configureWebViewInCell:cell];
    [[_webView scrollView] setContentOffset:CGPointMake(0, 0)];
    if (![[[cell contentView] subviews] containsObject:_webView])
        [[cell contentView] addSubview:_webView];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    if (_endedLoading) {
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"ItemListStoryboard" bundle:nil];
        NABookmarkDisplayViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:@"NABookmarkDisplayViewController"];
        [vc setWebView:_webView];
        [[viewController navigationController] pushViewController:vc animated:YES];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIWebviewDelegate
/*----------------------------------------------------------------------------*/
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:_webView hideActivityIndicator:YES animated:YES];
    _endedLoading = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:_webView hideActivityIndicator:YES animated:YES];
    NAAlertView * av = [[NAAlertView alloc] initWithError:error userInfo:nil];
    [av show];
    _endedLoading = YES;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)configureWebViewInCell:(UITableViewCell *)cell {
    CGRect frame = [[cell contentView] frame];
    frame.origin.x = -10;
    frame.size.width += 20;
    [_webView setFrame:frame];
    [_webView setDelegate:self];
    [_webView setUserInteractionEnabled:NO];
}

@end
