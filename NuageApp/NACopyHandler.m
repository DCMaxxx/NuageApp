//
//  NACopyHandler.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 08/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NACopyHandler.h"

#import "NAMacPickerViewController.h"
#import "NASettingsViewController.h"
#import "NABonjourClient.h"


@interface NACopyHandler () <DTBonjourDataConnectionDelegate>

@property (strong, nonatomic) NABonjourClient * client;
@property (strong, nonatomic) DTBonjourDataConnection * currentConnection;
@property (strong, nonatomic) NSURL * urlToCopy;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NACopyHandler


/*----------------------------------------------------------------------------*/
#pragma mark - Singleton
/*----------------------------------------------------------------------------*/
+ (NACopyHandler *)sharedInstance {
    static dispatch_once_t pred;
    static NACopyHandler *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[NACopyHandler alloc] init];
    });
    return shared;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)init {
    if (self = [super init]) {
        _client = [[NABonjourClient alloc] init];
        [_client setDelegate:self];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - NABonjourClientDelegate
/*----------------------------------------------------------------------------*/
- (void)didConnectToServer:(NSString *)server withConnection:(DTBonjourDataConnection *)connection {
    _currentConnection = connection;
    [_currentConnection setDelegate:self];
    if (_urlToCopy) {
        [self sendURLToMac:_urlToCopy];
        _urlToCopy = nil;
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - DTBonjourDataConnectionDelegate
/*----------------------------------------------------------------------------*/
- (void)connectionDidClose:(DTBonjourDataConnection *)connection {
    _currentConnection = nil;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc public methods
/*----------------------------------------------------------------------------*/
- (void)copyURL:(NSURL *)URL {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToClipboardKey])
        [[UIPasteboard generalPasteboard] setURL:URL];
    [self copyURLToMac:URL];
}

- (void)copyURLToMac:(NSURL *)URL {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCopyToMacClipboardKey]) {
        if (!_currentConnection) {
            NSString * serverName = [[NSUserDefaults standardUserDefaults] stringForKey:kDefautServerKey];
            [_client chooseServerWithName:serverName];
            _urlToCopy = URL;
        } else
            [self sendURLToMac:URL];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)sendURLToMac:(NSURL *)URL {
    NSError * error;
    [_currentConnection sendObject:[URL absoluteString] error:&error];
    if (error)
        NSLog(@"Error sending to Mac : %@", error);
}

@end
