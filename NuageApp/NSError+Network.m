//
//  NSError+Network.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NSError+Network.h"

@implementation NSError (Network)

- (BOOL)isNetworkError {
    return ([self code] == NSURLErrorNotConnectedToInternet
            || [self code] == NSURLErrorTimedOut
            || [self code] == NSURLErrorNetworkConnectionLost);
}

@end
