//
//  NANeedsRevealController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 07/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

@class PKRevealController;

@protocol NANeedsRevealController <NSObject>

- (void)configureWithRevealController:(PKRevealController *)controller;

@end
