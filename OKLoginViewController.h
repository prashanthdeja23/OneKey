//
//  OKLoginViewController.h
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface OKLoginViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView           *loginScrollView;
    IBOutlet UIButton               *goButton;
    IBOutlet UITextField            *userNameField;
    IBOutlet UITextField            *passwordField;
    IBOutlet UILabel                *loginFailed;
    IBOutlet UITextField            *serverField;
    
    IBOutlet UIActivityIndicatorView    *actIndicator;
    
    
}

- (IBAction)loginButtonClicked:(id)sender;

@end
