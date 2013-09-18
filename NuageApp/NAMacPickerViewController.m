//
//  NAMacPickerViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 08/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NAMacPickerViewController.h"

#import "NASettingsViewController.h"
#import "NABonjourClientDelegate.h"
#import "NABonjourClient.h"


@interface NAMacPickerViewController () <NABonjourClientDelegate>

@property (strong, nonatomic) NABonjourClient * client;
@property (strong, nonatomic) NSArray * servers;
@property (strong, nonatomic) NSString * serverName;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NAMacPickerViewController

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _client = [[NABonjourClient alloc] init];
        [_client setDelegate:self];
        _serverName = [[NSUserDefaults standardUserDefaults] stringForKey:kDefautServerKey];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDataSource
/*----------------------------------------------------------------------------*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_servers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MacCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSNetService * service = _servers[indexPath.row];
    [[cell textLabel] setText:[service name]];
    if ([[service name] isEqualToString:_serverName])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITableViewDelegate
/*----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_serverName length] && [[[cell textLabel] text] isEqualToString:_serverName])
        _serverName = nil;
    else
        _serverName = [[cell textLabel] text];

    [[NSUserDefaults standardUserDefaults] setObject:_serverName forKey:kDefautServerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self tableView] reloadData];
}


/*----------------------------------------------------------------------------*/
#pragma mark - NABonjourClientDelegate
/*----------------------------------------------------------------------------*/
- (void)didUpdateSevers:(NSArray *)servers {
    _servers = servers;
    [[self tableView] reloadData];
}

@end
