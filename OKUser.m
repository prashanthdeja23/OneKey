//
//  OKUser.m
//  OneKey
//
//  Created by PrashanthPukale on 8/6/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKUser.h"

static OKUser *user=nil;
extern NSString *DISABLE_APP;
extern NSString *OPEN_UNLOCKED;
extern NSString *SLIDER_SENSITIVITY;
extern NSString *SLIDER_KNOCKS;
extern NSString *OPMODE_KEY;

NSString *LOGGED_IN_KEY = @"LoggedInKey";
NSString *USER_INFO_KEY = @"UserInfoKey";

@implementation OKUser

+ (OKUser*)sharedUser
{
    [user reloadSettings];
    return user;
}

+ (void)initUserInfo:(NSString *)str
{
    user=[[OKUser alloc] initWithString:str];
}

+ (void)logoutUser
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LOGGED_IN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_INFO_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)didLoginWithUserInfo:(NSString*)userInfo
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGGED_IN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:USER_INFO_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self initUserInfo:userInfo];
}

+(void)resumeSession
{
    NSString *userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_KEY];
    [OKUser initUserInfo:userInfo];
}

+ (BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LOGGED_IN_KEY];
}

- (id)initWithString:(NSString*)infoString
{
    if (self=[super init])
    {
        NSArray *infoArray=[infoString componentsSeparatedByString:@"|"];
        for (NSString *str in infoArray)
        {
            if ([str hasPrefix:@"fn:"])
            {
                self.fName=[str substringFromIndex:3];
            }
            else if ([str hasPrefix:@"ln:"])
            {
                self.lName=[str substringFromIndex:3];
            }
            else if ([str hasPrefix:@"id:"])
            {
                self.idBitString=[str substringFromIndex:3];
            }
            else if([str hasPrefix:@"ti:"])
            {
                self.titleString=[str substringFromIndex:3];
            }
            else if([str hasPrefix:@"po:"])
            {
                self.potraitURLString=[str substringFromIndex:3];
            }
            else if ([str hasPrefix:@"cp:"])
            {
                self.certpass=[str substringFromIndex:3];
            }
            else if ([str hasPrefix:@"cc:"])
            {
                
                self.pk12Data=[[NSData alloc] initWithBase64EncodedString:[str substringFromIndex:3] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
            }
        }
    }
    
    
    return self;
}


- (NSData*)dataForId
{
    NSInteger length=[self.idBitString length];
    int             bitSize = (int)length;
    
    int byteSize = (bitSize + 8 - 1) / 8;
    
    byteSize=1;
    // hardcoded to check an issue.
    
    NSMutableData *dataBytes= [[NSMutableData alloc] initWithLength:byteSize];
    
    Byte x=0;
    
    for (int i=0;i<bitSize;i++)
    {
        int bytePosition=0; //(i/8);
        [dataBytes getBytes:&x range:NSMakeRange(bytePosition,1)];
        if ([_idBitString characterAtIndex:i]-'0')
        {
            x |= 1<<( 7-(i%8));
            
        }
        
        [dataBytes replaceBytesInRange:NSMakeRange(bytePosition,1) withBytes:&x length:1];
        
    }
    
    return dataBytes;
}

- (void)reloadSettings
{
    self.isAppDisabled=[[NSUserDefaults standardUserDefaults] boolForKey:DISABLE_APP];
    self.requiresScreenUnlock=[[NSUserDefaults standardUserDefaults] boolForKey:OPEN_UNLOCKED];
   _sensitivity = (int) [[NSUserDefaults standardUserDefaults] integerForKey:SLIDER_SENSITIVITY];
    _requiredKnocksCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:SLIDER_KNOCKS];
    _opMode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:OPMODE_KEY];
    if (!_opMode)
    {
        _opMode=BLEOperationModeKnock;
    }
    
}

- (float)minimumRssi
{
    return 65+((2-_sensitivity)*5);
}

@end
