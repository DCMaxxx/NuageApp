//
//  NADropBookmarkController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 05/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropBookmarkController.h"

#import "NADropItemPickerControllerDelegate.h"
#import "NSString+URL.h"
#import "NAAlertView.h"


@interface NADropBookmarkController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField * textField;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NADropBookmarkController


/*----------------------------------------------------------------------------*/
#pragma mark - NADropItemPickerController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithItem:(id)item {
    CGRect frame = [[cell contentView] frame];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, (CGRectGetHeight(frame) - 30) / 2, CGRectGetWidth(frame) - 40, 30)];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_textField setClearButtonMode:UITextFieldViewModeAlways];
    [_textField setKeyboardType:UIKeyboardTypeURL];
    [_textField setPlaceholder:@"Enter URL"];
    [_textField setDelegate:self];
    if (item)
        [self updateURL:item];
    [[cell contentView] addSubview:_textField];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)vc {
    [_textField becomeFirstResponder];
}

- (NSString *)itemPathExtenstion {
    return @"";
}

- (NSString *)missingItemMessage {
    return @"Looks like you're forgetting a link here";
}

- (NSString *)itemDescription {
    return @"bookmark";
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITextFieldDelegate
/*----------------------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString * text = [textField text];
    if ([text canBeConvertedToURL]) {
        [_textField resignFirstResponder];
        [self updateURL:[NSURL URLWithString:text]];
        return YES;
    } else {
        NAAlertView * av = [[NAAlertView alloc] initWithNAAlertViewKind:kAVRequiredField];
        [av setMessage:@"You text does not appear to be a valid URL"];
        [av show];
        return NO;
    }
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)updateURL:(NSURL *)url {
    [_textField setText:[url absoluteString]];
    if ([_delegate respondsToSelector:@selector(didFinishPickingItem:)])
        [_delegate didFinishPickingItem:url];
}

@end
