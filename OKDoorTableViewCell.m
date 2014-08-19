//
//  OKDoorTableViewCell.m
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKDoorTableViewCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation OKDoorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        // Initialization code
        doorDistance=[[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:doorDistance];
        
        doorName=[[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:doorName];
        
        self.backgroundColor=[UIColor clearColor];
        
        doorName.font=doorDistance.font=[UIFont boldSystemFontOfSize:13];
        doorDistance.textColor=doorName.textColor=[UIColor whiteColor];
        
        btnUnlock=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnUnlock setImage:[UIImage imageNamed:@"unlock.png"] forState:UIControlStateNormal];
        
        [self addSubview:btnUnlock];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    doorName.frame=CGRectMake(20, 7, 180, 30);
    doorDistance.frame=CGRectMake(200, 7, 60, 30);
    btnUnlock.frame=CGRectMake(270, 0, 40, 40);
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)display
{
    doorDistance.text=[NSString stringWithFormat:@"%.0f",[[self.doorInfo objectForKey:@"rssi"] floatValue]];
    doorName.text=[self.doorInfo objectForKey:@"name"];
    btnUnlock.hidden=NO;
}

@end
