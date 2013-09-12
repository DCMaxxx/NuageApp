//
//  NACopyHandler.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 08/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <DTBonjourDataConnection.h>

#import "NABonjourClientDelegate.h"


@interface NACopyHandler : NSObject <NABonjourClientDelegate>

+ (NACopyHandler *)sharedInstance;
- (BOOL)canCopyToMac;
- (void)copyURL:(NSURL *)URL;
- (void)copyURLToMac:(NSURL *)URL;

@end
