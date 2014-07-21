//
//  OKCustomSegue.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKCustomSegue.h"

@implementation OKCustomSegue

- (void)perform
{
    // Add your own animation code here.
    
    UIViewController* src = (UIViewController*) self.sourceViewController;
    UIViewController* dst = (UIViewController*) self.destinationViewController;
    [src addChildViewController:dst];
    [src.view addSubview:dst.view];
    
    //This line uses FLKAutolayout library to setup constraints
}

@end
