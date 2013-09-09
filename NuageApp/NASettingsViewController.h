//
//  NAAutoUploadViewController.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 31/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NANeedsRevealController.h"

#define kAutoUploadKey          @"auto-upload"
#define kCopyToClipboardKey     @"copy-to-clipboard"
#define kCopyToMacClipboardKey  @"copy-to-mac-clipboard"


@interface NASettingsViewController : UITableViewController <NANeedsRevealController>

@end