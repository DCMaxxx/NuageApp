//
//  NATextFieldCell.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NATextFieldCell.h"


@interface NATextFieldCell () <UITextFieldDelegate>

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NATextFieldCell

/*----------------------------------------------------------------------------*/
#pragma mark - Init
/*----------------------------------------------------------------------------*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGRect frame = [[self contentView] frame];
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(frame) - 40, CGRectGetHeight(frame) - 20)];
        [_textField setClearButtonMode:UITextFieldViewModeAlways];
        [_textField setDelegate:self];
        [[self contentView] addSubview:_textField];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}


/*----------------------------------------------------------------------------*/
#pragma mark - UITextFieldDelegate
/*----------------------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_cellDelegate respondsToSelector:@selector(textFieldShouldReturn:)])
        return [_cellDelegate textFieldShouldReturn:textField];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([_cellDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [_cellDelegate textFieldDidEndEditing:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([_cellDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [_cellDelegate textFieldShouldBeginEditing:textField];
    return YES;
}

@end
