//
//  NAAudioVideoCellController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAAudioVideoCellController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <CLWebItem.h>

#import "NAIconHandler.h"


@interface NAAudioVideoCellController ()

@property (strong, nonatomic) MPMoviePlayerViewController * player;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAudioVideoCellController

/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewItemCellController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    CGRect frame = [[cell contentView] frame];
    frame.origin.x -= 10.0f;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:[NAIconHandler imageWithKind:[webItem type]]];
    [[cell contentView] addSubview:imageView];

    _player = [[MPMoviePlayerViewController alloc] initWithContentURL:[webItem remoteURL]];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    [viewController presentMoviePlayerViewControllerAnimated:_player];
    [[_player moviePlayer] play];
}

@end
