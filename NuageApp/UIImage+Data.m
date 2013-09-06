//
//  UIImage+Data.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "UIImage+Data.h"

@implementation UIImage (Data)

- (NSData *)pngData {
    if ([self imageOrientation] != UIImageOrientationUp)
        [self rotate:[self imageOrientation]];
    return UIImagePNGRepresentation(self);
}

@end
