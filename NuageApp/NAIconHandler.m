//
//  NAIconHandler.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 02/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAIconHandler.h"

@implementation NAIconHandler

+ (UIImage *)iconWithKind:(CLWebItemType)kind {
    NSArray * kindIconNames = @[ @"image-icon.png",
                                 @"bookmark-icon.png",
                                 @"text-icon.png",
                                 @"archive-icon.png",
                                 @"audio-icon.png",
                                 @"video-icon.png",
                                 @"unknown-icon.png"
                                ];
    NSAssert([kindIconNames count] == CLWebItemTypeNone,
             @"Please update [NAIconHandler iconWithKind] array");
    UIImage * image = [UIImage imageNamed:kindIconNames[kind]];
    NSAssert(image,
             @"Unable to find icon in [NAIconHandler iconWithKind] (name %@)", kindIconNames[kind]);
    return image;
}

+ (UIImage *)imageWithKind:(CLWebItemType)kind {
    NSArray * kindIconNames = @[ @"image-large.png",
                                 @"bookmark-large.png",
                                 @"text-large.png",
                                 @"archive-large.png",
                                 @"audio-large.png",
                                 @"video-large.png",
                                 @"unknown-large.png"
                                 ];
    NSAssert([kindIconNames count] == CLWebItemTypeNone,
             @"Please update [NAIconHandler imageWithKind] array");
    UIImage * image = [UIImage imageNamed:kindIconNames[kind]];
    NSAssert(image,
             @"Unable to find icon in [NAIconHandler imageWithKind] (name %@)", kindIconNames[kind]);
    return image;
}

@end
