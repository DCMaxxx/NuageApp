//
//  NSString+URL.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (BOOL)canBeConvertedToURL {
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"];
}

@end
