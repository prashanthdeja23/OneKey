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
#import "OKBLEPeripheral.h"

#define CERT_ID "CA CERT"
#define KEY_STORED @"KEY_STORED"
#define CERT_FILE_NAME @"certificate.cer"

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
    
    NSLog(@"ip address = %@",[OKBLEPeripheral getServerIpForPeripheral:nil]);
    
    self.navigationItem.titleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titleImage.png"]];
    self.view.backgroundColor=[OKUtility colorFromHexString:@"A7EAFC"];

    usernameLabel.textColor=passLabel.textColor=[OKUtility colorFromHexString:@"148AB2"];
    
    [self getCert];
    
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
        
        NSString *urlString=[NSString stringWithFormat:@"%@:2061/?op=auth",server];
        NSDictionary *dictionaryForParams=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:userId,pass, nil] forKeys:[NSArray arrayWithObjects:@"userId",@"password", nil] ];
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *reponseSerializer=[AFHTTPResponseSerializer serializer];
        reponseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        
        
        manager.responseSerializer=reponseSerializer;
        
        AFSecurityPolicy *secPolicy =[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        secPolicy.validatesDomainName=NO;
        secPolicy.allowInvalidCertificates=YES;
        manager.securityPolicy=secPolicy;
        
        
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
            self.view.userInteractionEnabled=YES;
            self.view.alpha=1.0;
            [actIndicator stopAnimating];
        }];
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

- (void)getCert
{
    BOOL certStored=[[NSUserDefaults standardUserDefaults] boolForKey:KEY_STORED];
    if (!certStored)
    {
        //https://10.1.25.222:2061
        NSString *server=[serverField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *getCertURLString = [NSString stringWithFormat:@"%@:2061/?op=getCA",server];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *reponseSerializer=[AFHTTPResponseSerializer serializer];
        reponseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        
        manager.responseSerializer=reponseSerializer;
        AFSecurityPolicy *secPolicy =[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        secPolicy.pinnedCertificates=nil;
        secPolicy.allowInvalidCertificates=YES;
        manager.securityPolicy=secPolicy;
        
        [manager GET:[getCertURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"reponse string %@",operation.responseString);
             if ([operation.responseString rangeOfString:@"END CERTIFICATE"].location != NSNotFound )
             {
                 [self installRootCA:[operation.responseData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Failure %@",error);
         }];
    }
}

- (void)installRootCA:(NSData*)rootCertData
{
    
    OSStatus err = noErr;
    SecCertificateRef rootCert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef) rootCertData);
    
    CFTypeRef result;
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (__bridge id)kSecClassCertificate, kSecClass,
                          rootCert, kSecValueRef,
                          CERT_ID,kSecAttrLabel,
                          nil];
    
    err = SecItemAdd((__bridge CFDictionaryRef)dict, &result);
    
    [[NSUserDefaults standardUserDefaults] setObject:rootCertData forKey:@"CertData"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_STORED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if( err == noErr)
    {
        NSLog(@"Install root certificate success");
        
    }
    else if( err == errSecDuplicateItem )
    {
        NSLog(@"duplicate root certificate entry");
    }
    else
    {
        NSLog(@"install root certificate failure");
    }

}

- (NSData*)certForId:(NSString*)certId
{
//    OSStatus status = errSecSuccess;
//    CFTypeRef   certificateRef     = NULL;
//    // 1
//    const char *certLabelString = CERT_ID;
//    CFStringRef certLabel = CFStringCreateWithCString(
//                                                      NULL, certLabelString,
//                                                      kCFStringEncodingUTF8);         // 2
//    
//    const void *keys[] =   { kSecClass, kSecAttrLabel, kSecReturnData };
//    const void *values[] = { kSecClassCertificate, certLabel, kCFBooleanTrue };
//    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys,
//                                              values, 3,
//                                              NULL, NULL);       // 3
//    status = SecItemCopyMatching(dict, &certificateRef);        // 4
//    
//    if (status == errSecSuccess)
//    {
//        CFRelease(certificateRef);
//        certificateRef = NULL;
//    }
//    
//    /* Do something with certificateRef here */
//    
//    return (__bridge NSData*)certificateRef;

    //NSString* certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
    
    
    
    NSData* certData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cert" withExtension:@"cer"]];
    
    return certData;
}

//OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
//                                 SecIdentityRef *outIdentity,
//                                 SecTrustRef *outTrust,
//                                 CFStringRef keyPassword)
//{
//    OSStatus securityError = errSecSuccess;
//    
//    
//    const void *keys[] =   { kSecImportExportPassphrase };
//    const void *values[] = { keyPassword };
//    CFDictionaryRef optionsDictionary = NULL;
//    
//    /* Create a dictionary containing the passphrase if one
//     was specified.  Otherwise, create an empty dictionary. */
//    optionsDictionary = CFDictionaryCreate(
//                                           NULL, keys,
//                                           values, (keyPassword ? 1 : 0),
//                                           NULL, NULL);  // 1
//    
//    CFArrayRef items = NULL;
//    securityError = SecPKCS12Import(inPKCS12Data,
//                                    optionsDictionary,
//                                    &items);                    // 2
//    
//    
//    //
//    if (securityError == 0) {                                   // 3
//        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
//        const void *tempIdentity = NULL;
//        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
//                                             kSecImportItemIdentity);
//        CFRetain(tempIdentity);
//        *outIdentity = (SecIdentityRef)tempIdentity;
//        const void *tempTrust = NULL;
//        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
//        
//        CFRetain(tempTrust);
//        *outTrust = (SecTrustRef)tempTrust;
//    }
//    
//    if (optionsDictionary)                                      // 4
//        CFRelease(optionsDictionary);
//    
//    if (items)
//        CFRelease(items);
//    
//    return securityError;
//}

@end
