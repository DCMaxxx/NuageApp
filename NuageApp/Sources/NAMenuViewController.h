//
//  NAMainViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <PKRevealController.h>

@interface NAMenuViewController : UITableViewController

@property (strong, nonatomic) PKRevealController * myRevealController;
@property (strong, nonatomic) NSArray * viewControllers;

- (void)displayUploadConfirmAlertView;
- (void)displayLoginView;

@end
