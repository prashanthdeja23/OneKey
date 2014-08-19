//
//  OKSettingsViewController.h
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKUser.h"

@interface OKSettingsViewController : UIViewController
{
    IBOutlet UIButton *openWhenUnlockedButton;
    IBOutlet UIButton *openAnyTimeButton;
    
    IBOutlet UIButton *enableAppButton;
    IBOutlet UIButton *disableAppButton;
    
    
}

- (IBAction)sliderValueChanged:(UISlider*)slider;
- (IBAction)openDoorButtonClicked:(UIButton*)btn;
- (IBAction)enableAppButtonClicked:(UIButton*)btn;

@end
