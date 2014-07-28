//
//  OKContainerViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKContainerViewController.h"
#import "OKUtility.h"

#define SegueWelcome @"welcomeSegue"
#define SegueSettings @"SettingSegue"
#define SegueDoor @"DoorSegue"
#define SegueBadge @"BadgeSegue"

@interface OKContainerViewController ()

@property (strong, nonatomic) NSString *currentSegueIdentifier;

@end

@implementation OKContainerViewController

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
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[OKUtility colorFromHexString:@"2CA4CE"];
    // Show welcome Screen
    
    self.currentSegueIdentifier = SegueWelcome;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)currentViewControllerBackGroundColor
{
    if (self.childViewControllers.count)
    {
        return ((UIViewController*)self.childViewControllers[0]).view.backgroundColor;
    }
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([self.childViewControllers count])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:segue.destinationViewController];
        self.currentSegueIdentifier=segue.identifier;
    }
    else
    {
        [self addChildViewController:segue.destinationViewController];
        ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
        [segue.destinationViewController didMoveToParentViewController:self];
    }

}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}

- (void)loadViewAtIndex:(int)index
{
    if (index)
    {
        self.currentSegueIdentifier=(index==3)?SegueBadge:(index==2)?SegueDoor:SegueSettings;
    }
    else
    {
        self.currentSegueIdentifier=SegueWelcome;
    }
     [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
    
}
@end
