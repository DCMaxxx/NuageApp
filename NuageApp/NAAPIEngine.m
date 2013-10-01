//
//  NACloudAppEngine.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 28/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#define kKeychainItemIdentifier @"com.maxime-dechalendar.NuageApp"

#import <NSString+NPAdditions.h>
#import <KeychainItemWrapper.h>
#import <CLAPITransaction.h>

#import "NAAPIEngine.h"

@interface NAAPIEngine () <CLAPIEngineDelegate>

@property (strong, nonatomic) NSMutableArray * delegates;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAPIEngine

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
+ (instancetype)sharedEngine {
    static dispatch_once_t pred;
    static NAAPIEngine *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super initWithDelegate:self]) {
        _delegates = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<CLAPIEngineDelegate>)aDelegate {
    if (self = [super initWithDelegate:self]) {
        _delegates = [NSMutableArray array];
        [_delegates addObject:aDelegate];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc methods
/*----------------------------------------------------------------------------*/
- (void)logout {
    [self cancelAllConnections];
    [self setUserWithEmail:@"" andPassword:@""];
    _currentAccount = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAUserLogout" object:nil];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Getters and setters
/*----------------------------------------------------------------------------*/
- (void)addDelegate:(id<CLAPIEngineDelegate>)delegate {
    if (![_delegates containsObject:delegate])
        [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<CLAPIEngineDelegate>)delegate {
    [_delegates removeObject:delegate];
}

- (BOOL)loadUser {
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainItemIdentifier accessGroup:nil];
    _email = [keychainItem objectForKey:(__bridge NSString *)kSecAttrAccount];
    _password = [keychainItem objectForKey:(__bridge NSString *)kSecValueData];
    return [_email length] && [_password length];
}

- (void)setUserWithEmail:(NSString *)email andPassword:(NSString *)password {
    _email = email;
    _password = password;
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainItemIdentifier accessGroup:nil];
    [keychainItem setObject:email forKey:(__bridge NSString *)kSecAttrAccount];
    [keychainItem setObject:password forKey:(__bridge NSString *)kSecValueData];
}

- (NSString *)email {
    if (_email)
        return _email;
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainItemIdentifier accessGroup:nil];
    return [keychainItem objectForKey:(__bridge NSString *)kSecAttrAccount];
}

- (NSString *)password {
    if (_password)
        return _password;
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainItemIdentifier accessGroup:nil];
    return [keychainItem objectForKey:(__bridge NSString *)kSecValueData];
}

- (NSString *)uniqueName {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSDateFormatter * hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH:mm:ss"];
    NSDate * now = [NSDate date];
    NSString * name = [NSString stringWithFormat:@"NuageApp drop %@ at %@",
                       [[dateFormatter stringFromDate:now] stringByReplacingOccurrencesOfString:@"/" withString:@"-"],
                       [hourFormatter stringFromDate:now]];
    return name;
}

- (NSDictionary *)uploadDictionary {
    if (!_currentAccount)
        return nil;
    return [self uploadDictionaryForPrivacy:[[self currentAccount] uploadsArePrivate]];
}

- (NSDictionary *)uploadDictionaryForPrivacy:(BOOL)privacy {
    NSString * privateValue = privacy ? CLAPIEnginePrivacyOptionPrivate : CLAPIEnginePrivacyOptionPublic;
    return @{CLAPIEngineUploadOptionPrivacyKey:privateValue};
}

- (void)setDelegate:(id<CLAPIEngineDelegate>)delegate {
    NSAssert(false, @"You shouldn't use setDelegate, but addDelegate");
}


/*----------------------------------------------------------------------------*/
#pragma mark - CLAPIEngineDelegate
/*----------------------------------------------------------------------------*/
- (void)requestDidSucceedWithConnectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(requestDidSucceedWithConnectionIdentifier:userInfo:)])
            [delegate requestDidSucceedWithConnectionIdentifier:connectionIdentifier userInfo:userInfo];
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(requestDidFailWithError:connectionIdentifier:userInfo:)])
            [delegate requestDidFailWithError:error connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)fileUploadDidProgress:(CGFloat)percentageComplete connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(fileUploadDidProgress:connectionIdentifier:userInfo:)])
            [delegate fileUploadDidProgress:percentageComplete connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(fileUploadDidSucceedWithResultingItem:connectionIdentifier:userInfo:)])
            [delegate fileUploadDidSucceedWithResultingItem:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)linkBookmarkDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(linkBookmarkDidSucceedWithResultingItem:connectionIdentifier:userInfo:)])
            [delegate linkBookmarkDidSucceedWithResultingItem:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)accountUpdateDidSucceed:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(accountUpdateDidSucceed:connectionIdentifier:userInfo:)])
            [delegate accountUpdateDidSucceed:account connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)itemUpdateDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(itemUpdateDidSucceed:connectionIdentifier:userInfo:)])
            [delegate itemUpdateDidSucceed:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)itemDeletionDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(itemDeletionDidSucceed:connectionIdentifier:userInfo:)])
            [delegate itemDeletionDidSucceed:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)itemRestorationDidSucceed:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(itemRestorationDidSucceed:connectionIdentifier:userInfo:)])
            [delegate itemRestorationDidSucceed:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)itemInformationRetrievalSucceeded:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(itemInformationRetrievalSucceeded:connectionIdentifier:userInfo:)])
            [delegate itemInformationRetrievalSucceeded:item connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)accountInformationRetrievalSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(accountInformationRetrievalSucceeded:connectionIdentifier:userInfo:)])
            [delegate accountInformationRetrievalSucceeded:account connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)itemListRetrievalSucceeded:(NSArray *)items connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(itemListRetrievalSucceeded:connectionIdentifier:userInfo:)])
            [delegate itemListRetrievalSucceeded:items connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)accountCreationSucceeded:(CLAccount *)newAccount connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(accountCreationSucceeded:connectionIdentifier:userInfo:)])
            [delegate accountCreationSucceeded:newAccount connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)storeProductInformationRetrievalSucceeded:(NSArray *)productIdentifiers connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(storeProductInformationRetrievalSucceeded:connectionIdentifier:userInfo:)])
            [delegate storeProductInformationRetrievalSucceeded:productIdentifiers connectionIdentifier:connectionIdentifier userInfo:userInfo];
    
}

- (void)storeReceiptRedemptionSucceeded:(CLAccount *)account connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
    for (id<CLAPIEngineDelegate> delegate in _delegates)
        if (userInfo == delegate
            && [delegate respondsToSelector:@selector(storeReceiptRedemptionSucceeded:connectionIdentifier:userInfo:)])
            [delegate storeReceiptRedemptionSucceeded:account connectionIdentifier:connectionIdentifier userInfo:userInfo];
}


@end





