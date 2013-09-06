//
//  NADropItemViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropItemPickerController.h"
#import "NANeedsEngine.h"


@interface NADropItemViewController : UITableViewController <NANeedsEngine>

@property id<NADropItemPickerController> dropPickerController;
@property id item;

@end
