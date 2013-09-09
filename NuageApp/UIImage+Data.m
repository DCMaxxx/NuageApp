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
    UIImage * image = self;
    if ([image imageOrientation] != UIImageOrientationUp)
        image = [image rotate:[image imageOrientation]];
    return UIImagePNGRepresentation(image);
}

@end
