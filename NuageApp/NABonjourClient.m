//
//  NABonjourClient.m
//  Test
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NABonjourClient.h"

@interface NABonjourClient () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, DTBonjourDataConnectionDelegate>

@property (strong, nonatomic) NSNetServiceBrowser * serviceBrowser;
@property (strong, nonatomic) NSMutableArray * servers;
@property (nonatomic) NSNetService * currentService;

@end

@implementation NABonjourClient

+ (NABonjourClient *)sharedInstance {
    static dispatch_once_t pred;
    static NABonjourClient *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[NABonjourClient alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _servers = [NSMutableArray array];
        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
        [_serviceBrowser setDelegate:self];
        [_serviceBrowser searchForServicesOfType:@"_NuageApp._tcp." inDomain:@""];
    }
    return self;
}

- (BOOL)isReady {
    return _currentConnection && [_currentConnection isOpen];
}


- (void)chooseServer:(NSUInteger)idx {
    if ([_servers count] > idx) {
        NSLog(@"Choosing server : %@", _servers[idx]);
        _currentService = _servers[idx];
        _currentConnection = [[DTBonjourDataConnection alloc] initWithService:_currentService];
        [_currentConnection setDelegate:self];
        [_currentConnection open];
    }
}

- (void)connectionDidClose:(DTBonjourDataConnection *)connection {
    NSLog(@"Connection closed");
    _currentConnection = nil;
    [self chooseServer:0];
}

#pragma mark - NetServiceBrowser Delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"Found server : %@", aNetService);
    [aNetService setDelegate:self];
	[aNetService startMonitoring];
    [_servers addObject:aNetService];
    [self chooseServer:0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    NSLog(@"Removed server : %@", aNetService);
    _currentConnection = nil;
    [_servers removeObject:aNetService];
}

@end
