//
//  NAListItemsViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 02/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <PKRevealController.h>

#import "NAItemViewControllerDelegate.h"
#import "NANeedsRevealController.h"
#import "NANeedsEngine.h"
#import "NAItemUpdate.h"

@interface NAListItemsViewController : UITableViewController <NANeedsEngine,
NAItemViewControllerDelegate,
NAItemUpdate,
NANeedsRevealController>

@end
