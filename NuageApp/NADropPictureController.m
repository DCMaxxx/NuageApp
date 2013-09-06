//
//  NADropPictureViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NADropPictureController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>

#import "NATextFieldCell.h"
#import "UIImage+Data.h"
#import "NASwitchCell.h"
#import "NAAPIEngine.h"
#import "NAAlertView.h"

#define kCameraSourceButtonIndex    0
#define kLibrarySourceButtonIndex   1


@interface NADropPictureController () <UIImagePickerControllerDelegate,
                                           UINavigationControllerDelegate,
                                           UIActionSheetDelegate>

@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;

@property (strong, nonatomic) UIViewController * tmpViewController;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NADropPictureController

/*----------------------------------------------------------------------------*/
#pragma mark - NAItemPickerController
/*----------------------------------------------------------------------------*/
- (void)cell:(UITableViewCell *)cell didLoadWithItem:(id)item {
    _imagePickerController = [[UIImagePickerController alloc] init];
    [_imagePickerController setDelegate:self];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(95, 0, 111, 111)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    if (item)
        [self changedImage:item];
    else
        [_imageView setImage:[UIImage imageNamed:@"upload-large.png"]];
    [[cell contentView] addSubview:_imageView];
}

- (void)cell:(UITableViewCell *)cell wasTappedOnViewController:(UIViewController *)vc {
    if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"Source"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Library", nil];
            [as showInView:[vc view]];
            _tmpViewController = vc;
            return ;
        }
        else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            [_imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [vc presentViewController:_imagePickerController animated:YES completion:nil];
}

- (NSString *)itemPathExtenstion {
    return @"png";
}

- (NSString *)missingItemMessage {
    return @"You need to pick an image first !";
}

- (NSString *)itemDescription {
    return @"picture";
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIImagePickerControllerDelegate
/*----------------------------------------------------------------------------*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self changedImage:info[UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


/*----------------------------------------------------------------------------*/
#pragma mark - UIActionSheetDelegate
/*----------------------------------------------------------------------------*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == kCameraSourceButtonIndex)
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    else if (buttonIndex == kLibrarySourceButtonIndex)
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    else
        return ;
    [_tmpViewController presentViewController:_imagePickerController animated:YES completion:nil];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Misc private methods
/*----------------------------------------------------------------------------*/
- (void)changedImage:(UIImage *)image {
    _image = image;
    [_imageView setImage:_image];
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(didFinishPickingItem:)])
            [_delegate didFinishPickingItem:[image pngData]];
    }    
}

@end
