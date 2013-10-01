//
//  NAIconHandler.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 02/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <CLWebItem.h>


@interface NAIconHandler : NSObject

+ (UIImage *)iconWithKind:(CLWebItemType)kind;
+ (UIImage *)imageWithKind:(CLWebItemType)kind;

@end
