//
//  UIActionSheet+ButtonState.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "UIActionSheet+ButtonState.h"


@implementation UIActionSheet (ButtonState)

- (void)setButton:(NSInteger)buttonIndex toState:(BOOL)enabled {
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)]) {
                    UIButton * button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            buttonIndex--;
        }
    }
}

@end
