//
//  NAItemDropPickerController.h
//  
//
//  Created by Maxime de Chalendar on 05/09/13.
//
//

@class      UITableViewCell;
@protocol   NADropPickerControllerDelegate;

@protocol NADropItemPickerController <NSObject>

- (void)cell:(UITableViewCell *)cell didLoadWithItem:(id)item;
- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)vc;

- (NSString *)itemDescription;
- (NSString *)missingItemMessage;
- (NSString *)itemPathExtenstion;

@optional
@property (weak, nonatomic) id<NADropPickerControllerDelegate> delegate;

@end
