//
//  NAImageViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 01/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAImageCellController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <CLWebItem.h>

#import "NAImageDisplayViewController.h"
#import "MBProgressHUD+Network.h"
#import "NSError+Network.h"
#import "NAAlertView.h"


@interface NAImageCellController ()

@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UIImage * image;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAImageCellController

/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewItemCellController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    __block UIImageView * imageView = [[UIImageView alloc] initWithFrame:[[cell contentView] frame]];
    _imageView = imageView;
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [MBProgressHUD showHUDAddedTo:_imageView withText:@"Loading image..." showActivityIndicator:NO animated:YES];

    NSURLRequest * request = [NSURLRequest requestWithURL:[webItem remoteURL]];
    __weak NAImageCellController * weakSelf = self;
    [_imageView setImageWithURLRequest:request
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse * response, UIImage *image) {
                                   [MBProgressHUD hideHUDForView:imageView animated:YES];
                                   [imageView setImage:image];
                                   [weakSelf setImage:image];
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                   [MBProgressHUD hideHUDForView:imageView animated:YES];
                                   NAAlertView * av;
                                   if ([error isNetworkError]) {
                                       av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVConnection];
                                   } else {
                                       av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
                                       NSLog(@"Other error on NAImageCellController : %@", error);
                                   }
                                   [av show];
                               }];
    [cell addSubview:_imageView];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    if (_image) {
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"ItemsStoryboard" bundle:nil];
        NAImageDisplayViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:@"NAImageDisplayViewController"];
        [vc setImage:_image];
        [[viewController navigationController] pushViewController:vc animated:YES];
    }
}

@end
