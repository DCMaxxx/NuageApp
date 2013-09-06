//
//  NATextFieldCell.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 29/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NATextFieldCellDelegate.h"

@interface NATextFieldCell : UITableViewCell

@property (strong, nonatomic) id<NATextFieldCellDelegate> cellDelegate;
@property (strong, nonatomic) UITextField * textField;

@end
