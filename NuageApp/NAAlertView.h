//
//  NAAlertView.h
//  NuageApp
//
//  Created by Maxime de Chalendar on 31/08/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

typedef enum {
    kAVRequiredField,
    kAVFailedLogin,
    kAVFailedRegistering,
    kAVFailedUpload,
    kAVNetwork,
    kAVPremium,
    kAVGeneric,
    kAVNone
} NAAlertViewKind;


@interface NAAlertView : UIAlertView

- (id)initWithNAAlertViewKind:(NAAlertViewKind)kind;
- (id)initWithError:(NSError *)error userInfo:(id)userInfo;

@end
