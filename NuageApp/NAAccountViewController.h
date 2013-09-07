//
//  NAAccountViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <PKRevealController.h>

#import "NANeedsRevealController.h"
#import "NANeedsEngine.h"


@interface NAAccountViewController : UITableViewController <NANeedsEngine, NANeedsRevealController>

@end
