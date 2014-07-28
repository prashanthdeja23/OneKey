//
//  OKMainViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKMainViewController.h"
#import "OKUtility.h"

#define WELCOME_TAG 110
#define SETTINGS_TAG 111
#define DOORS_TAG 112
#define BADGE_TAG 113
#define CONFIRM_LOGOUT 114

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

{
    if (alertView.tag==CONFIRM_LOGOUT)
    {
        if (buttonIndex!=alertView.cancelButtonIndex)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    
    // Do any additional setup after loading the view.
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
        
        [UIView animateWithDuration:0.25 animations:^{
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
        
        [UIView animateWithDuration:0.25 animations:^{
            self.btnsView.center=CGPointMake(self.btnsView.center.x, self.btnsView.center.y+yDx);
            [self.containerView setFrame:newRect];
            self.profileInfoView.alpha=1.0;
            
        } completion:^(BOOL finished) {
            
            
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

@end
