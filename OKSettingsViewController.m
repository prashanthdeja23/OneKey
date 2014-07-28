//
//  OKSettingsViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKSettingsViewController.h"
#import "OKUtility.h"


#define SLIDER_SENSITIVITY_TAG 111
#define SLIDER_KNOCKS_TAG 112

#define OPEN_UNLOCKED @"ANYTIME"
#define DISABLE_APP @"ENABLE"

@interface OKSettingsViewController ()
{
    IBOutlet UISlider       *sensitivitySlider;
    IBOutlet UISlider       *knocksSlider;
    IBOutlet UILabel        *sensitivityLabel;
    IBOutlet UILabel        *knocksLable;
}



@end

@implementation OKSettingsViewController

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
    
    
    self.view.backgroundColor = [OKUtility colorFromHexString:@"2CA4CE"];
    
    sensitivitySlider.value=1.0;
    knocksSlider.value=1.0;
    
    openAnyTimeButton.selected=YES;
    enableAppButton.selected=YES;
    
    sensitivitySlider.tag=SLIDER_SENSITIVITY_TAG;
    knocksSlider.tag=SLIDER_KNOCKS_TAG;
    
    NSInteger sensitivity=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"slider%d",SLIDER_SENSITIVITY_TAG]];
    NSInteger knocks=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"slider%d",SLIDER_KNOCKS_TAG]];
    
    sensitivitySlider.value=sensitivity;
    knocksSlider.value=knocks;
    
    BOOL disable=[[NSUserDefaults standardUserDefaults] boolForKey:DISABLE_APP];
    if (!disable)
    {
        enableAppButton.selected=YES;
        disableAppButton.selected=NO;
    }
    else
    {
        enableAppButton.selected=NO;
        disableAppButton.selected=YES;
    }
    
    BOOL openUnlocked=[[NSUserDefaults standardUserDefaults] boolForKey:OPEN_UNLOCKED];
    if (!openUnlocked)
    {
        openAnyTimeButton.selected=YES;
        openWhenUnlockedButton.selected=NO;
    }
    else
    {
        openAnyTimeButton.selected=NO;
        openWhenUnlockedButton.selected=YES;
    }
    // Do any additional setup after loading the view.
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
- (IBAction)openDoorButtonClicked:(UIButton*)btn
{
    if (btn==openAnyTimeButton)
    {
        if (!openAnyTimeButton.selected)
        {
            openAnyTimeButton.selected=YES;
            openWhenUnlockedButton.selected=NO;
        }
    }
    else
    {
        if (!openWhenUnlockedButton.selected)
        {
            openAnyTimeButton.selected=NO;
            openWhenUnlockedButton.selected=YES;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:!openAnyTimeButton.selected forKey:OPEN_UNLOCKED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)enableAppButtonClicked:(UIButton*)btn
{
    if (btn==enableAppButton)
    {
        if (!enableAppButton.selected)
        {
            enableAppButton.selected=YES;
            disableAppButton.selected=NO;
        }
    }
    else
    {
        if (!disableAppButton.selected)
        {
            disableAppButton.selected=YES;
            enableAppButton.selected=NO;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:!enableAppButton.selected forKey:DISABLE_APP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sliderValueChanged:(UISlider*)slider
{
    //Do Nothin.
    
}

- (IBAction)sliderTouchEnd:(UISlider*)slider
{
    
    [slider setValue:(int)round(slider.value) animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)slider.value forKey:[NSString stringWithFormat:@"slider%d",(int)slider.tag]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(UIImage *)imageFromText:(NSString *)text
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:15.0];
    
     NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [OKUtility colorFromHexString:@"2CA4CE"]};
    
    CGSize size  = [text sizeWithAttributes:attributes];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:attributes];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
