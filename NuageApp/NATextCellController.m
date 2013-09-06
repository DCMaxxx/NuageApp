//
//  NATextPreviewCellController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NATextCellController.h"

#import <AFNetworking.h>
#import <CLWebItem.h>

#import "NATextDisplayViewController.h"
#import "MBProgressHUD+Network.h"
#import "NSError+Network.h"
#import "NAAlertView.h"


@interface NATextCellController ()

@property (strong, nonatomic) UILabel * label;
@property (strong, nonatomic) NSString * fullText;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NATextCellController

/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewCellViewController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    CGRect frame = [[cell contentView] frame];
    frame.origin.x -= 5;
    _label = [[UILabel alloc] initWithFrame:frame];
    [_label setBackgroundColor:[UIColor clearColor]];
    [_label setNumberOfLines:10];
    [[cell contentView] addSubview:_label];
    [MBProgressHUD showHUDAddedTo:_label withText:@"Loading text..." showActivityIndicator:NO animated:YES];
    
    NSURL * baseURL = [[NSURL URLWithString:@"/" relativeToURL:[webItem remoteURL]] absoluteURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    NSURLRequest * request = [client requestWithMethod:@"GET" path:[[webItem remoteURL] path] parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:_label animated:YES];
        _fullText = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [_label setText:_fullText];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:_label animated:YES];
        NAAlertView * av;
        if ([error isNetworkError])
            av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
        else {
            av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
            NSLog(@"Other error on NATextCellController : %@", error);
        }
        [av show];
    }];
    [operation start];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    if (_fullText) {
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"ItemsStoryboard" bundle:nil];
        NATextDisplayViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:@"NATextDisplayViewController"];
        [vc setFullText:_fullText];
        [[viewController navigationController] pushViewController:vc animated:YES];
    }
}

@end
