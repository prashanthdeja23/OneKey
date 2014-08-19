//
//  OKBadgeViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKBadgeViewController.h"
#import "OKUtility.h"
#import "OKUser.h"

@interface OKBadgeViewController ()

@end

@implementation OKBadgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    OKUser *user=[OKUser sharedUser];
    nameLabel.text=[user.fName  stringByAppendingFormat:@" %@",user.lName];
    titleLabel.text=[user titleString];
    [self.profileImageView setImageURL:[NSURL URLWithString:user.potraitURLString]];
    
    // Do any additional setup after loading the view.
    [self.profileImageView roundWithCornerRadius:self.profileImageView.bounds.size.width/2.0];
    [self.profileImageView addBorderWithColor:[OKUtility colorFromHexString:@"2CA4CE"] andWidth:12];
    self.view.backgroundColor=[OKUtility colorFromHexString:@"1482B2"];
    allAccessButton.backgroundColor=[OKUtility colorFromHexString:@"0DDF00"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
