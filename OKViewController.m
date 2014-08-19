//
//  OKViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/15/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKViewController.h"
#import "OKUser.h"
#import "OKMainViewController.h"
#import "OKLoginViewController.h"



@interface OKViewController ()
{
}

@end

@implementation OKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    if ([OKUser isLoggedIn])
    {
        [OKUser resumeSession];
        [self showMainScreen];
    }
    else
    {
        [self showLoginScreen];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSString *serviceUUID=;
//    [_manager connectToPeripheralWithService:[NSArray arrayWithObject:serviceUUID]];
   // [_locationManager startRangingBeaconsInRegion:[[OKBeaconManager sharedManager] regionToBeRanged]];
    
}

- (void)showLoginScreen
{
    UIStoryboard *mainBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id mainScreen=[mainBoard instantiateViewControllerWithIdentifier:@"Login"];
    NSArray *uivewControllers=[NSArray arrayWithObject:mainScreen];
    [self.navigationController setViewControllers:uivewControllers];
}

- (void)showMainScreen
{
    UIStoryboard *mainBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id mainScreen=[mainBoard instantiateViewControllerWithIdentifier:@"MainVC"];
    NSArray *uivewControllers=[NSArray arrayWithObject:mainScreen];
    [self.navigationController setViewControllers:uivewControllers];
    
   // [self.navigationController presentViewController:navController animated:YES completion:nil];
}



@end
