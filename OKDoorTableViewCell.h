//
//  OKDoorTableViewCell.h
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKDoorTableViewCell : UITableViewCell
{
    UILabel                 *doorName;
    UILabel                 *doorDistance;
    UIButton                *btnUnlock;
}

@property (nonatomic,strong) NSDictionary *doorInfo;

- (void)display;

@end
