//
//  OKBadgeViewController.h
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface OKBadgeViewController : UIViewController
{
    IBOutlet UIButton               *allAccessButton;
    IBOutlet UILabel                *nameLabel;
    IBOutlet UILabel                *titleLabel;
    
}
@property (nonatomic,strong) IBOutlet    AsyncImageView         *profileImageView;

@end
