//
//  OKLoginViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/21/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKLoginViewController.h"
#import "OKUtility.h"
#import "OKUser.h"
#import "OKBLEManager.h"

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
        [UIView animateWithDuration:0.25 animations:^
        {
            
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
    
    [self callLoginService];
}


- (void)callLoginService
{
    NSString *userId=[userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pass=[passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *server=[serverField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (userId.length && pass.length && server.length)
    {
        self.view.userInteractionEnabled=NO;
        self.view.alpha=0.7;
        [actIndicator startAnimating];
        NSString *urlString=[NSString stringWithFormat:@"http://%@",serverField.text];
        
        NSDictionary *dictionaryForParams=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:userId,pass, nil] forKeys:[NSArray arrayWithObjects:@"userId",@"password", nil] ];
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *reponseSerializer=[AFHTTPResponseSerializer serializer];
        reponseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        
        manager.responseSerializer=reponseSerializer;
        
        [manager POST:urlString parameters:dictionaryForParams success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSString *userInfo=operation.responseString;
            
            if (userInfo!=nil && ![userInfo isEqualToString:@"invalid"])
            {
                [OKUser didLoginWithUserInfo:userInfo];
                [self performSelector:@selector(pushMainScreen) withObject:nil afterDelay:0.3];
            }
            else
            {
                // Invalid login ..
                [self showLoginFailed:YES];
            }
            self.view.userInteractionEnabled=YES;
            self.view.alpha=1.0;
            [actIndicator stopAnimating];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            
            // Error ..
        }];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            
//            NSString *userInfo=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:NULL];
//            
//            dispatch_async(dispatch_get_main_queue(), ^
//            {
//                
//                
//                
//            });
//            
//        });
        
    }
    else
    {
        // Show toast for invalid user name and pass.
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
