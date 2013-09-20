//
//  NABonjourClient.m
//  Test
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NABonjourClient.h"


@interface NABonjourClient () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) NSNetServiceBrowser * serviceBrowser;
@property (strong, nonatomic) NSMutableArray * servers;
@property (strong, nonatomic) NSString * serverToConnect;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NABonjourClient

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)init {
    if (self = [super init]) {
        _servers = [NSMutableArray array];
        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
        [_serviceBrowser setDelegate:self];
        [_serviceBrowser searchForServicesOfType:@"_NuageApp._tcp." inDomain:@""];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - NSNetServiceBrowserDelegate
/*----------------------------------------------------------------------------*/
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [aNetService setDelegate:self];
	[aNetService startMonitoring];
    [_servers addObject:aNetService];
    if (_serverToConnect)
        [self chooseServerWithName:_serverToConnect];
    if (!moreComing && _delegate && [_delegate respondsToSelector:@selector(didUpdateSevers:)])
        [_delegate didUpdateSevers:[_servers copy]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    [_servers removeObject:aNetService];
    if (!moreComing && _delegate && [_delegate respondsToSelector:@selector(didUpdateSevers:)])
        [_delegate didUpdateSevers:[_servers copy]];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc public methods
/*----------------------------------------------------------------------------*/
- (void)chooseServerWithIndex:(NSUInteger)idx {
    if ([_servers count] > idx) {
        NSNetService * currentService = _servers[idx];
        DTBonjourDataConnection * currentConnection = [[DTBonjourDataConnection alloc] initWithService:currentService];
        [currentConnection open];
        if (_delegate && [_delegate respondsToSelector:@selector(didConnectToServer:withConnection:)])
            [_delegate didConnectToServer:[currentService name] withConnection:currentConnection];
    }
}

- (void)chooseServerWithName:(NSString *)name {
    NSUInteger i = 0;
    _serverToConnect = name;
    for (NSNetService * server in _servers) {
        if ([[server name] isEqualToString:name]) {
            [self chooseServerWithIndex:i];
            _serverToConnect = nil;
            break ;
        }
        ++i;
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - Getters
/*----------------------------------------------------------------------------*/
- (NSArray *)servers {
    return [_servers copy];
}

@end
