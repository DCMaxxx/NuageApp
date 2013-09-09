//
//  NABonjourClient.h
//  Test
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <DTBonjourDataConnection.h>

#import "NABonjourClientDelegate.h"


@interface NABonjourClient : NSObject

@property (strong, nonatomic) id<NABonjourClientDelegate> delegate;

- (void)chooseServerWithIndex:(NSUInteger)idx;
- (void)chooseServerWithName:(NSString *)name;

@end
