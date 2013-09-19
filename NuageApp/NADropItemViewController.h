//
//  NADropItemViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAItemViewControllerDelegate.h"
#import "NADropItemPickerController.h"

@interface NADropItemViewController : UITableViewController

@property (weak, nonatomic) id<NAItemViewControllerDelegate> delegate;
@property (strong, nonatomic) id<NADropItemPickerController> dropPickerController;
@property (strong, nonatomic) id item;

@end
