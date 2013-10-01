//
//  NAImageDisplayViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAImageDisplayViewController.h"


@interface NAImageDisplayViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAImageDisplayViewController


/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:@"Image viewer"];
    
    _imageView = [[UIImageView alloc] initWithImage:_image];
    CGRect imageViewFrame = CGRectMake(0, 0, [_image size].width,  [_image size].height);
    [_imageView setFrame:imageViewFrame];
    [_scrollView addSubview:_imageView];
    [_scrollView setContentSize:[_image size]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect scrollViewFrame = [_scrollView frame];
    CGFloat scaleWidth = CGRectGetWidth(scrollViewFrame) / [_scrollView contentSize].width;
    CGFloat scaleHeight = CGRectGetHeight(scrollViewFrame) / [_scrollView contentSize].height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);

    [_scrollView setMinimumZoomScale:minScale];
    [_scrollView setMaximumZoomScale:5.0f];
    [_scrollView setZoomScale:minScale];

    [self centerScrollViewContents];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIScrollViewDelegate
/*----------------------------------------------------------------------------*/
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interactions
/*----------------------------------------------------------------------------*/
- (IBAction)doubleTappedScrollView:(UITapGestureRecognizer *)sender {
    CGPoint pointInView = [sender locationInView:_imageView];
    CGFloat newZoomScale = [_scrollView zoomScale] * 1.5f;
    newZoomScale = MIN(newZoomScale, [_scrollView maximumZoomScale]);
    CGSize scrollViewSize = [_scrollView bounds].size;
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}



/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)centerScrollViewContents {
    CGSize boundsSize = [_scrollView bounds].size;
    CGRect contentsFrame = [_imageView frame];
    
    contentsFrame.origin.x = 0.0f;
    if (contentsFrame.size.width < boundsSize.width)
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    
    contentsFrame.origin.y = 0.0f;
    if (contentsFrame.size.height < boundsSize.height)
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    
    [_imageView setFrame:contentsFrame];
}

@end
