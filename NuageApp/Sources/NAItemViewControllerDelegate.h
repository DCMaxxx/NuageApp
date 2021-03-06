//
//  NAItemUpdate.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

@class CLWebItem;

@protocol NAItemViewControllerDelegate <NSObject>

- (void)item:(CLWebItem *)item wasUpdatedToItem:(CLWebItem *)updatedItem;
- (void)addedNewItem:(CLWebItem *)item;

@end
