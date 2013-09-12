//
//  NAItemViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 01/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <CLWebItem.h>

#import "NAItemViewControllerDelegate.h"
#import "NATransparentCell.h"
#import "NATextFieldCell.h"
#import "NANeedsEngine.h"
#import "NASwitchCell.h"


@interface NAItemViewController : UITableViewController <NANeedsEngine>

@property (weak, nonatomic) IBOutlet NATextFieldCell *itemNameCell;
@property (weak, nonatomic) IBOutlet NATransparentCell *itemPreviewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemLinkCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *itemPrivateCell;

@property (weak, nonatomic) id<NAItemViewControllerDelegate> delegate;
@property (strong, nonatomic) CLWebItem * webItem;

- (void)configureWithItem:(CLWebItem *)item;

@end
