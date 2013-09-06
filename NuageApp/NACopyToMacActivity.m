//
//  NACopyToMacActivity.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NACopyToMacActivity.h"

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
    return [UIImage imageNamed:@"account-icon.png"]; //TODO : Fix this
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return [activityItems count] == 1 && [activityItems[0] isKindOfClass:[NSString class]];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    _link = activityItems[0];
}

- (void)performActivity {
    //TODO : Something very cool here
}

@end
