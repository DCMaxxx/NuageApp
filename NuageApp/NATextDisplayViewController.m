//
//  NATextDisplayViewController.m
//  NuageApp
//
//  Created by Maxime de Chalendar on 04/09/13.
//  Copyright (c) 2013 Maxime de Chalendar. All rights reserved.
//

#import "NATextDisplayViewController.h"


@interface NATextDisplayViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


/*----------------------------------------------------------------------------*/
#pragma mark - Implementation
/*----------------------------------------------------------------------------*/
@implementation NATextDisplayViewController

/*----------------------------------------------------------------------------*/
#pragma mark - UIVIewController
/*----------------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [_textView setText:_fullText];
}

@end
