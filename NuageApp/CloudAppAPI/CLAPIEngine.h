//
//  CLAPIEngine.h
//  Cloud
//
//  Created by Nick Paulson on 7/20/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAPIEngineDelegate.h"
#import "CLAPIEngineConstants.h"
#import "CLWebItem.h"
#import "CLAccount.h"

// Upload options
extern NSString *const CLAPIEngineUploadOptionPrivacyKey; // Value is CLAPIEnginePrivacyOptionPrivate or CLAPIEnginePrivacyOptionPublic

extern NSString *const CLAPIEnginePrivacyOptionPrivate;
extern NSString *const CLAPIEnginePrivacyOptionPublic;

@interface CLAPIEngine : NSObject {
	NSString *_email;
	NSString *_password;
    NSURL *_baseURL;
	id<CLAPIEngineDelegate> __unsafe_unretained _delegate;
	
	NSMutableSet *_transactions;
	
	BOOL _clearsCookies;
}

@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSString *password;
@property (nonatomic, readwrite, unsafe_unretained) id<CLAPIEngineDelegate> delegate;
@property (nonatomic, readwrite, strong) NSURL *baseURL;
@property (nonatomic, readwrite, strong) NSMutableSet *transactions;

// This property makes the engine clear the cookies before making a new connection.  
// This can be helpful when credentials are "stuck."
@property (nonatomic, readwrite, assign) BOOL clearsCookies;

- (id)initWithDelegate:(id<CLAPIEngineDelegate>)aDelegate;
+ (id)engine;
+ (id)engineWithDelegate:(id<CLAPIEngineDelegate>)aDelegate;

// Returns whether or not the email/password fields are complete.
- (BOOL)isReady;

// Base URL for connections, usually http://my.cl.ly/
+ (NSURL *)defaultBaseURL;

// Cancel the connection with identifier
- (void)cancelConnection:(NSString *)connectionIdentifier;

// Cancel all connections
- (void)cancelAllConnections;

- (id)userInfoForConnectionIdentifier:(NSString *)identifier;
- (CLAPIRequestType)requestTypeForConnectionIdentifier:(NSString *)identifier;

- (NSString *)createAccountWithEmail:(NSString *)accountEmail password:(NSString *)accountPassword acceptTerms:(BOOL)acceptTerms userInfo:(id)userInfo;
- (NSString *)changePrivacyOfItem:(CLWebItem *)webItem toPrivate:(BOOL)isPrivate userInfo:(id)userInfo;
- (NSString *)changePrivacyOfItemAtHref:(NSURL *)href toPrivate:(BOOL)isPrivate userInfo:(id)userInfo;
- (NSString *)changeNameOfItem:(CLWebItem *)webItem toName:(NSString *)newName userInfo:(id)userInfo;
- (NSString *)changeNameOfItemAtHref:(NSURL *)href toName:(NSString *)newName userInfo:(id)userInfo;
- (NSString *)getAccountInformationWithUserInfo:(id)userInfo;
- (NSString *)getItemInformation:(CLWebItem *)item userInfo:(id)userInfo;
- (NSString *)getItemInformationAtURL:(NSURL *)itemURL userInfo:(id)userInfo;
- (NSString *)bookmarkLinkWithURL:(NSURL *)URL name:(NSString *)name userInfo:(id)userInfo;
- (NSString *)uploadFileWithName:(NSString *)fileName fileData:(NSData *)fileData userInfo:(id)userInfo;
- (NSString *)bookmarkLinkWithURL:(NSURL *)URL name:(NSString *)name options:(NSDictionary *)options userInfo:(id)userInfo;
- (NSString *)uploadFileWithName:(NSString *)fileName fileData:(NSData *)fileData options:(NSDictionary *)options userInfo:(id)userInfo;
- (NSString *)deleteItem:(CLWebItem *)webItem userInfo:(id)userInfo;
- (NSString *)deleteItemAtHref:(NSURL *)href userInfo:(id)userInfo;
- (NSString *)restoreItem:(CLWebItem *)webItem userInfo:(id)userInfo;
- (NSString *)restoreItemAtHref:(NSURL *)href userInfo:(id)userInfo;
- (NSString *)getItemListStartingAtPage:(NSInteger)pageNumStartingAtOne itemsPerPage:(NSInteger)perPage userInfo:(id)userInfo;
- (NSString *)getItemListStartingAtPage:(NSInteger)pageNumStartingAtOne ofType:(CLWebItemType)type itemsPerPage:(NSInteger)perPage userInfo:(id)userInfo;
- (NSString *)getItemListStartingAtPage:(NSInteger)pageNumStartingAtOne ofType:(CLWebItemType)type itemsPerPage:(NSInteger)perPage showOnlyItemsInTrash:(BOOL)showOnlyItemsInTrash userInfo:(id)userInfo;

- (NSString *)getStoreProductsWithUserInfo:(id)userInfo;
- (NSString *)redeemStoreReceipt:(NSString *)base64Receipt userInfo:(id)userInfo;

// NuageApp addons
- (NSString *)changePrivacyOfAccount:(CLAccount *)account userInfo:(id)userInfo;
- (NSString *)changeToEmail:(NSString *)newEmail withPassword:(NSString *)password userInfo:(id)userInfo;
- (NSString *)changeToPassword:(NSString *)newEmail withCurrentPassword:(NSString *)password userInfo:(id)userInfo;
- (NSString *)updateCustomDomain:(NSString *)customDomain customDomainHome:(NSString *)customDomainHome userInfo:(id)userInfo;

@end
