//
//  OKSettingsViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKSettingsViewController.h"
#import "OKUtility.h"
#import "OKBLEManager.h"

#define SLIDER_SENSITIVITY_TAG 111
#define SLIDER_KNOCKS_TAG 112

#define PROX_BUTTON 113
#define KNOCK_BUTTON 114
#define PROX_KNOCK_BUTTON 115

NSString * OPEN_UNLOCKED = @"ANYTIME";
NSString * DISABLE_APP = @"ENABLE";
NSString * SLIDER_SENSITIVITY = @"slider111";
NSString * SLIDER_KNOCKS = @"slider112";
NSString * OPMODE_KEY = @"OPMODEKEY";


@interface OKSettingsViewController ()
{
    IBOutlet UISlider       *sensitivitySlider;
    IBOutlet UISlider       *knocksSlider;
    IBOutlet UILabel        *sensitivityLabel;
    IBOutlet UILabel        *knocksLable;
}

@property (nonatomic)OKUser *user;
@property (nonatomic)NSInteger selectedModeTag;


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
    
    self.user=[OKUser sharedUser];
    [self.user reloadSettings];
    
    self.view.backgroundColor = [OKUtility colorFromHexString:@"2CA4CE"];
    
    sensitivitySlider.value=1.0;
    knocksSlider.value=1.0;
    
    openAnyTimeButton.selected=YES;
    enableAppButton.selected=YES;
    
    sensitivitySlider.tag=SLIDER_SENSITIVITY_TAG;
    knocksSlider.tag=SLIDER_KNOCKS_TAG;
    
    NSInteger sensitivity=self.user.sensitivity;
    NSInteger knocks=self.user.requiredKnocksCount;
    
    sensitivitySlider.value=sensitivity;
    knocksSlider.value=knocks;
    
    if (!self.user.isAppDisabled)
    {
        enableAppButton.selected=YES;
        disableAppButton.selected=NO;
    }
    else
    {
        enableAppButton.selected=NO;
        disableAppButton.selected=YES;
    }
    
    if (!self.user.requiresScreenUnlock)
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
    if ((self.user.opMode>=BLEOperationModeProx&&self.user.opMode<=BLEOperationModeProxKnock)||(self.user.opMode=114))
    {
        [self setOpMode:self.user.opMode];
    }
    
}

- (void)setOpMode:(int)mode
{
//   self.knockButton.selected = self.proxKnockButton.selected = self.proxButton.selected=NO;
//    self.selectedModeTag=mode;
//    UIButton *btn = (UIButton*)[self.view viewWithTag:mode];
//    btn.selected=YES;

    [opModeButton setBackgroundImage:[self backgroundImageForOpMode:mode] forState:UIControlStateNormal];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)backgroundImageForOpMode:(enum BLEOperationMode)opMode
{
    NSString *baseImageName=@"proxKnock";
    
    if (opMode == BLEOperationModeKnock)
    {
        return [UIImage imageNamed:[baseImageName stringByAppendingString:@"1.png"]];
    }
    else if (opMode == BLEOperationModeProx)
    {
        return [UIImage imageNamed:[baseImageName stringByAppendingString:@"2.png"]];
    }
    else
    {
        return [UIImage imageNamed:[baseImageName stringByAppendingString:@"3.png"]];
    }
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
    OKBLEManager *manager=[OKBLEManager sharedManager];
    
    if (btn==enableAppButton)
    {
        if (!enableAppButton.selected)
        {
            enableAppButton.selected=YES;
            disableAppButton.selected=NO;
            
            [manager startScanForDoors];
        }
    }
    else
    {
        if (!disableAppButton.selected)
        {
            disableAppButton.selected=YES;
            enableAppButton.selected=NO;
            
            [manager disableBLE];
        }
    }
    

    [[NSUserDefaults standardUserDefaults] setBool:!enableAppButton.selected forKey:DISABLE_APP];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.user reloadSettings];
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
    [self.user reloadSettings];
}

- (IBAction)selectOpModeClicked:(UIButton*)sender
{
    if (self.user.opMode==BLEOperationModeProxKnock)
    {
        self.user.opMode=BLEOperationModeProx;
    }
    else
    {
        self.user.opMode++;
    }
    self.selectedModeTag=self.user.opMode;
    [self setOpMode:self.user.opMode];
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.user.opMode forKey:OPMODE_KEY];
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
