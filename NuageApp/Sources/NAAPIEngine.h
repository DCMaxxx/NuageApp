//
//  NACloudAppEngine.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 28/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLAPIEngine.h>


@interface NAAPIEngine : CLAPIEngine

@property (strong, nonatomic) CLAccount * currentAccount;

+ (instancetype)sharedEngine;

- (void)addDelegate:(id<CLAPIEngineDelegate>)delegate;
- (void)removeDelegate:(id<CLAPIEngineDelegate>)delegate;

- (void)setUserWithEmail:(NSString *)email andPassword:(NSString *)password;
- (BOOL)loadUser;
- (void)logout;
- (NSString *)email;
- (NSString *)password;

- (NSString *)uniqueName;
- (NSDictionary *)uploadDictionary;
- (NSDictionary *)uploadDictionaryForPrivacy:(BOOL)privacy;

@end
