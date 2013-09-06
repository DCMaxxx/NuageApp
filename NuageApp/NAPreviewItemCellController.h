//
//  NAPreviewItemCellController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 02/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

@class UIViewController;
@class UITableViewCell;
@class CLWebItem;

@protocol NAPreviewItemCellController <NSObject>

- (void)cell:(UITableViewCell *)cell didLoadWithWebItem:(CLWebItem *)webItem;
- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)viewController withWebItem:(CLWebItem *)webItem;

@optional
- (void)cell:(UITableViewCell *)cell willAppearWithWebItem:(CLWebItem *)webItem;

@end
