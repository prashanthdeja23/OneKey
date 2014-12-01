//
//  OKMainViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKMainViewController.h"
#import "OKUtility.h"
#import "OKUser.h"
#import "AsyncImageView.h"
#import "OKBLEManager.h"
#import <QuartzCore/QuartzCore.h>

#define WELCOME_TAG 110
#define SETTINGS_TAG 111
#define DOORS_TAG 112
#define BADGE_TAG 113
#define CONFIRM_LOGOUT 114

extern NSString *LOGGED_IN_KEY;
extern NSString *DID_OPEN_DOOR_NOTIFICATION;
extern NSString *BLUETOOTh_STATE_CHANGED;

@interface OKMainViewController ()

@property (nonatomic) NSInteger selectedButtonTag;

@end

@implementation OKMainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)logoutClicked:(UIButton*)logoutButton
{
    [logoutButton setEnabled:NO];
    UIAlertView *confirmAlert= [[UIAlertView alloc] initWithTitle:@"Logout?" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    confirmAlert.tag=CONFIRM_LOGOUT;
    [confirmAlert show];
    [logoutButton setEnabled:YES];
}


- (void)logout
{
    UIStoryboard *mainBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id mainScreen=[mainBoard instantiateViewControllerWithIdentifier:@"Login"];
    NSArray *controllers=[NSArray arrayWithObject:mainScreen];
    [self.navigationController setViewControllers:controllers animated:YES];
    [OKUser logoutUser];
    OKBLEManager *manager=[OKBLEManager sharedManager];
    [manager stopDiscovery];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

{
    if (alertView.tag==CONFIRM_LOGOUT)
    {
        if (buttonIndex!=alertView.cancelButtonIndex)
        {
            [self logout];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    OKBLEManager *manager=[OKBLEManager sharedManager];
    
    
    OKUser *user=[OKUser sharedUser];
    if (!user.isAppDisabled)
    {
        [manager startScanForDoors];
    }
    else
    {
        [manager stopDiscovery];
    }
    
    nameLabel.text=[[user fName] stringByAppendingFormat:@" %@",[user lName] ];
    titleLabel.text=[user titleString];
    [self.profileImageView setImageURL:[NSURL URLWithString:user.potraitURLString]];
    
    self.view.backgroundColor=[OKUtility colorFromHexString:@"16719E"];
    
    self.navigationItem.titleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titleImage.png"]];
   
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout.png"] style:UIBarButtonItemStylePlain target:self  action:@selector(logoutClicked:)];
    
    self.selectedButtonTag=WELCOME_TAG;
    
    // Btns BG setting
    UIButton *settingBtn= (UIButton*)[self.view viewWithTag:SETTINGS_TAG];
    [settingBtn setBackgroundColor:[OKUtility colorFromHexString:@"2CA4CE"]];
    
    UIButton *doorsButton=(UIButton*) [self.view viewWithTag:DOORS_TAG];
    [doorsButton setBackgroundColor:[OKUtility colorFromHexString:@"1B96C1"]];
    
    UIButton *badgeButton=(UIButton*) [self.view viewWithTag:BADGE_TAG];
    [badgeButton setBackgroundColor:[OKUtility colorFromHexString:@"1482B2"]];
    
    [self.profileImageView roundWithCornerRadius:self.profileImageView.bounds.size.width/2.0];
    [self.profileImageView addBorderWithColor:[OKUtility colorFromHexString:@"2CA4CE"] andWidth:4];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnlockedMsg:) name:DID_OPEN_DOOR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged:) name:BLUETOOTh_STATE_CHANGED object:nil];
    
    // Do any additional setup after loading the view.
    
    if (!manager.isBluetoothOn)
    {
        [self showAlert:@"Bluetooth is turned off. Please turn it on"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
    }
}


- (IBAction)badgeImageClicked:(UIButton*)btn
{
    UIButton *badgeButton=(UIButton*)[self.btnsView viewWithTag:BADGE_TAG];
    [self clickedOptionsButton:badgeButton];
}


- (void)repositionViewsForBadge:(BOOL)show
{
    if (show)
    {
        // Reposition to show badge view
        CGRect btnsViewFrame=self.btnsView.frame;
        float yDx=btnsViewFrame.origin.y;
        CGRect oldRect=self.containerView.frame;
        oldRect.origin.y=oldRect.origin.y-yDx;
        oldRect.size.height+=yDx;
        CGRect newRect=oldRect;
        
        self.containerViewController.view.backgroundColor=[self.containerViewController currentViewControllerBackGroundColor];
        
        [UIView animateWithDuration:0.25 animations:^
        {
            self.btnsView.center=CGPointMake(self.btnsView.center.x, self.btnsView.center.y-yDx);
            [self.containerView setFrame:newRect];
            
            self.profileInfoView.alpha=0.0;
            
        } completion:^(BOOL finished) {
            
            [self.containerViewController loadViewAtIndex:(int)(self.selectedButtonTag-WELCOME_TAG)];
            
        }];
        
    }
    else
    {
        // Reposition to hide badge view
        float yDx=self.profileInfoView.frame.size.height+self.profileInfoView.frame.origin.y;
        
        CGRect oldRect=self.containerView.frame;
        oldRect.origin.y=oldRect.origin.y+yDx;
        oldRect.size.height-=yDx;
        CGRect newRect=oldRect;
        
        [UIView animateWithDuration:0.25 animations:^
        {
            self.btnsView.center=CGPointMake(self.btnsView.center.x, self.btnsView.center.y+yDx);
            [self.containerView setFrame:newRect];
            self.profileInfoView.alpha=1.0;
            
        } completion:^(BOOL finished)
        {
            
            
            [self.containerViewController loadViewAtIndex:(int)(self.selectedButtonTag-WELCOME_TAG)];
            
        }];
    }
}
- (IBAction)clickedOptionsButton:(UIButton*)btn
{
    if (btn.tag!=self.selectedButtonTag)
    {
        [btn setSelected:YES];
        
        UIButton *btnPrevious=(UIButton*)[self.view viewWithTag:self.selectedButtonTag];
        
        if (btnPrevious!=nil&&[btnPrevious isSelected])
        {
            [btnPrevious setSelected:NO];
        }
     
        
        if (btn.tag!=BADGE_TAG)
        {
      
            if (self.selectedButtonTag==BADGE_TAG)
            {
                self.selectedButtonTag=btn.tag;
                [self repositionViewsForBadge:NO];
            }
            else
            {
                [self.containerViewController loadViewAtIndex:(int)(btn.tag-WELCOME_TAG)];
                self.selectedButtonTag=btn.tag;
            }
            
        }
        else if(btn.tag == BADGE_TAG && self.selectedButtonTag!=BADGE_TAG)
        {
            [self repositionViewsForBadge:YES];
            self.selectedButtonTag=btn.tag;
        }
        else
        {
            //DO Nothing.
        }
    }
}

- (void)bluetoothStateChanged:(NSNotification*)notification
{
    OKBLEManager *manager=[OKBLEManager sharedManager];
    if (manager.isBluetoothOn)
    {
        [self showAlert:@"Bluetooth turned on, Looking for doors."];
    }
    else
    {
        [self showAlert:@"Please turn on bluetooth and try again."];
    }
}

- (void)showUnlockedMsg:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    
    
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(40, self.view.bounds.size.height-160, self.view.bounds.size.width-80, 50)];
    newView.backgroundColor=[UIColor lightGrayColor];
    
    UILabel *unlockedLabel = [[UILabel alloc] initWithFrame:newView.bounds];
    unlockedLabel.backgroundColor=[UIColor clearColor];
    
    NSString *nameStr=[NSString stringWithFormat:@"Unlocked %@",[dict objectForKey:@"peripheralName"]];
    
    if (nameStr.length==16)
    {
        unlockedLabel.text=[nameStr substringFromIndex:10];
    }
    else
    {
        unlockedLabel.text=nameStr;
    }
    
    
    unlockedLabel.font=[UIFont boldSystemFontOfSize:12];
    unlockedLabel.textAlignment=NSTextAlignmentCenter;
    newView.alpha=0.0;
    [newView addSubview:unlockedLabel];
    
    newView.layer.cornerRadius=5.0;
    newView.layer.masksToBounds=YES;
    
    [((UIViewController*)[self.navigationController.viewControllers lastObject]).view addSubview:newView];
    
    [UIView animateWithDuration:0.50 animations:^
    {
        newView.alpha=0.6;
    } completion:^(BOOL finished)
    {
        [newView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.0];
    }];
}

- (void)showAlert:(NSString*)alert
{
    alertLabel.text=alert;
    alertLabel.alpha=0.0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.45f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationRepeatAutoreverses:YES];
    
    alertLabel.alpha=1.0;
    
    [UIView commitAnimations];
    
}

@end
