//
//  NAAutoUploadViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 31/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NASettingsViewController.h"

#import <PKRevealController.h>

#import "NASwitchCell.h"
#import "NAAlertView.h"


@interface NASettingsViewController ()

@property (strong, nonatomic) PKRevealController *revealController;
@property (weak, nonatomic) IBOutlet NASwitchCell *autoUploadCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *cpLinkToClipboardCell;
@property (weak, nonatomic) IBOutlet NASwitchCell *cpLinkToMacClipboardCell;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NASettingsViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureCell:_autoUploadCell withSettingKey:kAutoUploadKey];
    [self configureCell:_cpLinkToClipboardCell withSettingKey:kCopyToClipboardKey];
    [self configureCell:_cpLinkToMacClipboardCell withSettingKey:kCopyToMacClipboardKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureWithRevealController:_revealController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*----------------------------------------------------------------------------*/
#pragma mark - User interaction
/*----------------------------------------------------------------------------*/
- (void)switchWasChanged:(UISwitch *)switchView {
    NSString * key = nil;
    if (switchView == [_autoUploadCell switchView])
        key = kAutoUploadKey;
    else if (switchView == [_cpLinkToClipboardCell switchView])
        key = kCopyToClipboardKey;
    else if (switchView == [_cpLinkToMacClipboardCell switchView])
        key = kCopyToMacClipboardKey;

    if (key) {
        [[NSUserDefaults standardUserDefaults] setBool:[switchView isOn] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - NANeedsRevealController
/*----------------------------------------------------------------------------*/
- (void)configureWithRevealController:(PKRevealController *)controller {
    _revealController = controller;
    [[[self navigationController] navigationBar] addGestureRecognizer:[_revealController revealPanGestureRecognizer]];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem.png"] style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(displayMenu)];
    [[self navigationItem] setLeftBarButtonItem:item];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Changing view controller
/*----------------------------------------------------------------------------*/
- (void)displayMenu {
    [_revealController showViewController:[_revealController leftViewController] animated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"NAMacPickerSegue"]
        && ![[_cpLinkToMacClipboardCell switchView] isOn]) {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVGeneric];
        [av setTitle:@"You're doing it wrong !"];
        [av setMessage:@"Please enable copy to Mac first"];
        [av show];
        return NO;
    }
    return YES;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)configureCell:(NASwitchCell *)cell withSettingKey:(NSString *)key {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    [[cell switchView] setOn:enabled animated:YES];
    [[cell switchView] addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
}

@end
