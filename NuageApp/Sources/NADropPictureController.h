//
//  NADropPictureViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropItemPickerControllerDelegate.h"
#import "NADropItemPickerController.h"

@interface NADropPictureController : NSObject <NADropItemPickerController>

@property (weak, nonatomic) id<NADropPickerControllerDelegate> delegate;

@end
