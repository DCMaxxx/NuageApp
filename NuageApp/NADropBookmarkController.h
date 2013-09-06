//
//  NADropBookmarkController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropItemPickerController.h"

@interface NADropBookmarkController : NSObject <NADropItemPickerController>

@property (strong, nonatomic) id<NADropPickerControllerDelegate> delegate;

@end
