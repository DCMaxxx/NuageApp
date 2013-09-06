//
//  MBProgressHUD+Network.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "MBProgressHUD+Network.h"

#import <AFNetworkActivityIndicatorManager.h>


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation MBProgressHUD (Network)

/*----------------------------------------------------------------------------*/
#pragma mark - Misc methods
/*----------------------------------------------------------------------------*/
+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view
                         withText:(NSString *)text
            showActivityIndicator:(BOOL)activityIndicator
                         animated:(BOOL)animated {
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    [hud setLabelText:text];
	[view addSubview:hud];
	[hud show:animated];
    if (activityIndicator)
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
	return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view
 hideActivityIndicator:(BOOL)activityIndicator
              animated:(BOOL)animated {
    if (activityIndicator)
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
	MBProgressHUD *hud = [self HUDForView:view];
	if (hud != nil) {
		hud.removeFromSuperViewOnHide = YES;
		[hud hide:animated];
		return YES;
	}
	return NO;
}

@end
