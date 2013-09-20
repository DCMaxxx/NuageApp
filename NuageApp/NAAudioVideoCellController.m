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

#import "MBProgressHUD+Network.h"
#import "NAIconHandler.h"
#import "NAAlertView.h"

@interface NAAudioVideoCellController ()

@property (strong, nonatomic) MPMoviePlayerViewController * player;
@property (strong, nonatomic) UIImageView * previewView;
@property (strong, nonatomic) UIImageView * playView;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAudioVideoCellController

/*----------------------------------------------------------------------------*/
#pragma mark - NAPreviewItemCellController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem {
    _player = [[MPMoviePlayerViewController alloc] initWithContentURL:[webItem remoteURL]];
    [[_player moviePlayer] setShouldAutoplay:NO];
    [[_player moviePlayer] prepareToPlay];

    CGRect frame = [[cell contentView] frame];
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 7.0)
        frame.origin.x -= 10.0f;

    _previewView = [[UIImageView alloc] initWithFrame:frame];
    [_previewView setContentMode:UIViewContentModeScaleAspectFit];
    [_previewView setImage:[NAIconHandler imageWithKind:[webItem type]]];
    UIImage * play = [UIImage imageNamed:@"play-icon.png"];
    UIImageView * playView = [[UIImageView alloc] initWithImage:play];
    [playView setCenter:[_previewView center]];
    [playView setOpaque:NO];
    [_previewView addSubview:playView];
    [[cell contentView] addSubview:_previewView];

    if ([webItem type] == CLWebItemTypeVideo) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toto:)
                                                     name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                                   object:nil];
        [[_player moviePlayer] requestThumbnailImagesAtTimes:@[@(1.0f)] timeOption:MPMovieTimeOptionNearestKeyFrame];
    }
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem {
    [viewController presentMoviePlayerViewControllerAnimated:_player];
    [[_player moviePlayer] play];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Notification Obersavtion
/*----------------------------------------------------------------------------*/
- (void)toto:(NSNotification *)notification {
    NSDictionary * dic = [notification userInfo];
    if (dic[MPMoviePlayerThumbnailErrorKey]) {
        NAAlertView * av = [[NAAlertView alloc] initWithError:dic[MPMoviePlayerThumbnailErrorKey] userInfo:nil];
        [av show];
    } else {
        UIImage * image = dic[MPMoviePlayerThumbnailImageKey];
        [_previewView setImage:image];
    }
}
@end
