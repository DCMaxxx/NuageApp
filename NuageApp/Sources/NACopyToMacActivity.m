//
//  NACopyToMacActivity.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NASettingsViewController.h"
#import "NACopyToMacActivity.h"
#import "NACopyHandler.h"

@interface NACopyToMacActivity ()

@property (strong, nonatomic) NSString * link;

@end


@implementation NACopyToMacActivity

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
    return @"Copy to Mac";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"mac-icon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return [activityItems count] == 1
    && [activityItems[0] isKindOfClass:[NSString class]]
    && [[NACopyHandler sharedInstance] canCopyToMac];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    _link = activityItems[0];
}

- (void)performActivity {
    [[NACopyHandler sharedInstance] copyURLToMac:[NSURL URLWithString:_link]];
    [self activityDidFinish:YES];
}

@end
