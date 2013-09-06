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

@interface NAAPIEngine ()

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAAPIEngine

/*----------------------------------------------------------------------------*/
#pragma mark - Misc methods
/*----------------------------------------------------------------------------*/
- (void)logout {
    [self setUserWithEmail:@"" andPassword:@""];
    _currentAccount = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NAUserLogout" object:nil];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Getters and setters
/*----------------------------------------------------------------------------*/
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

@end





