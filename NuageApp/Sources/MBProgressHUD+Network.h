//
//  MBProgressHUD+Network.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Network)

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view
                         withText:(NSString *)text
            showActivityIndicator:(BOOL)activityIndicator
                         animated:(BOOL)animated;

+ (BOOL)hideHUDForView:(UIView *)view
 hideActivityIndicator:(BOOL)activityIndicator
              animated:(BOOL)animated;
@end
