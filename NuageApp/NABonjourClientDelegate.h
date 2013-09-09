//
//  NABonjourClientDelegate.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 08/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

@class DTBonjourDataConnection;

@protocol NABonjourClientDelegate <NSObject>

@optional
- (void)didConnectToServer:(NSString *)server withConnection:(DTBonjourDataConnection *)connection;
- (void)didUpdateSevers:(NSArray *)servers;

@end
