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
{
    IBOutlet UILabel                 *nameLabel;
    IBOutlet UILabel                 *titleLabel;
    
}
- (IBAction)clickedOptionsButton:(UIButton*)btn;

@property (nonatomic, weak) OKContainerViewController *containerViewController;
@property (nonatomic,strong) IBOutlet UIView                   *containerView;
@property (nonatomic,strong) IBOutlet UIView                   *btnsView;
@property (nonatomic,strong) IBOutlet UIView                   *profileInfoView;
@property (nonatomic,strong) IBOutlet UIImageView              *profileImageView;

- (IBAction)badgeImageClicked:(UIButton*)btn;


@end
