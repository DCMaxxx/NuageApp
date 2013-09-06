//
//  NABonjourClient.m
//  Test
//
//  Created by Maxime de Chalendar on 06/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NABonjourClient.h"

//@interface NABonjourClient () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
//
//@property (strong, nonatomic) NSNetServiceBrowser * serviceBrowser;
//@property (strong, nonatomic) NSMutableArray * servers;
//@property (nonatomic) NSNetService * currentService;
//
//@end
//
//@implementation NABonjourClient
//
//+ (NABonjourClient *)sharedInstance {
//    static dispatch_once_t pred;
//    static SCSettingsHandler *shared = nil;
//    dispatch_once(&pred, ^{
//        shared = [[NABonjourClient alloc] init];
//    });
//    return shared;
//}
//
//- (id)init {
//    if (self = [super init]) {
//        _servers = [NSMutableArray array];
//        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
//        [_serviceBrowser setDelegate:self];
//        [_serviceBrowser searchForServicesOfType:@"_NuageApp._tcp." inDomain:@""];
//    }
//    return self;
//}
//
//- (void)chooseServer:(NSUInteger)idx {
//    _currentService = _servers[idx];
//    NSLog(@"Choosed a service : %@", _currentService);
//    _currentConnection = [[DTBonjourDataConnection alloc] initWithService:_currentService];
//    [_currentConnection open];
//}
//
//#pragma mark - NetServiceBrowser Delegate
//- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
//           didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
//    NSLog(@"Found a service : %@", aNetService);
//    [aNetService setDelegate:self];
//	[aNetService startMonitoring];
//    [_servers addObject:aNetService];
//    [self chooseServer:0];
//}
//
//- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
//         didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
//    _currentConnection = nil;
//    [_servers removeObject:aNetService];
//}
//
//@end
