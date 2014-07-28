//
//  OKLoginViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKLoginViewController.h"
#import "OKUtility.h"

@interface OKLoginViewController ()
{
    IBOutlet UILabel            *usernameLabel;
    IBOutlet UILabel            *passLabel;
}

@property (nonatomic)BOOL isKeyBoardUp;
@end

@implementation OKLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)registerForKeyBoardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deRegisterForKeyBoardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titleImage.png"]];
    self.view.backgroundColor=[OKUtility colorFromHexString:@"A7EAFC"];

    usernameLabel.textColor=passLabel.textColor=[OKUtility colorFromHexString:@"148AB2"];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self registerForKeyBoardNotifications];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self deRegisterForKeyBoardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(id)notification
{
    [self scrollViewToTop:YES];
}

-(void)keyboardWillHide:(id)notification
{
    [self scrollViewToTop:NO];
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



-(void)scrollViewToTop:(BOOL)toTop
{
    float displacement=140;
    if (toTop)
    {
        [UIView animateWithDuration:0.25 animations:^{
            
        } ];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.center=CGPointMake(self.view.center.x, self.view.center.y-displacement);
        } completion:nil];
    }
    else
    {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.center=CGPointMake(self.view.center.x, self.view.center.y+displacement);
        } completion:nil];
    }
}

- (BOOL)isValidLogin
{
    return (userNameField.text.length && passwordField.text.length);
}

- (void)showLoginFailed:(BOOL)show
{
    loginFailed.hidden=!show;
}

- (void)pushMainScreen
{
    userNameField.text=passwordField.text=@"";
    
    UIStoryboard *mainBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id mainScreen=[mainBoard instantiateViewControllerWithIdentifier:@"MainVC"];
    UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:mainScreen];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)loginButtonClicked:(id)sender
{
    [userNameField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    if ([self isValidLogin])
    {
        [self showLoginFailed:NO];
        [self pushMainScreen];
    }
    else
    {
        [self showLoginFailed:YES];
    }
}

#pragma mark - textFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([self isValidLogin])
    {
        [textField resignFirstResponder];
        [self showLoginFailed:NO];
        return YES;
    }
    else
    {
        [self showLoginFailed:YES];
    }
    
    return NO;
}
#pragma mark end -


@end
