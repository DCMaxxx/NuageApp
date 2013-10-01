//
//  NATextFieldCellDelegate.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 03/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NATextFieldCellDelegate <NSObject>

@optional
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end
