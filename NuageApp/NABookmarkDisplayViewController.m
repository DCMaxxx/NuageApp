//
//  NABookmarkViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NABookmarkDisplayViewController.h"


@interface NABookmarkDisplayViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) NSURL * currentURL;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NABookmarkDisplayViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*--------------------------------------------------------------------x--------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:@"Bookmark viewer"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect webViewFrame = [[self view] frame];
    CGRect toolbarFrame = [_toolbar frame];
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer >= 7.0) {
        CGRect navigationBarFrame = [[[self navigationController] navigationBar] frame];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        webViewFrame.size.height -= (CGRectGetHeight(navigationBarFrame) + CGRectGetHeight(toolbarFrame) + CGRectGetHeight(statusBarFrame));
        webViewFrame.origin.y += (CGRectGetHeight(navigationBarFrame) + CGRectGetHeight(statusBarFrame));
    } else
        webViewFrame.size.height -= CGRectGetHeight(toolbarFrame);
    [_webView setFrame:webViewFrame];
    [_webView setUserInteractionEnabled:YES];
    [_webView setDelegate:self];
    [[self view] addSubview:_webView];
    [self updateToobalButtons];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIWebViewDelegate
/*----------------------------------------------------------------------------*/
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateToobalButtons];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)tappedPreviousButton:(id)sender {
    [_webView goBack];
    [self updateToobalButtons];
}

- (IBAction)tappedNextButton:(id)sender {
    [_webView goForward];
    [self updateToobalButtons];
}

- (IBAction)tappedRefreshButton:(id)sender {
    [_webView reload];
}

- (IBAction)tappedOpenInSafariButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[[[_webView request] URL] absoluteURL]];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)updateToobalButtons {
    [_previousButton setEnabled:[_webView canGoBack]];
    [_nextButton setEnabled:[_webView canGoForward]];    
}

@end
