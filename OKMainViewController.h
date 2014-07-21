//
//  OKMainViewController.h
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKContainerViewController.h"
@interface OKMainViewController : UIViewController

- (IBAction)clickedOptionsButton:(UIButton*)btn;

@property (nonatomic, weak)IBOutlet OKContainerViewController *containerViewController;


@end
