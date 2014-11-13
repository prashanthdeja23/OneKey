//
//  OKUser.h
//  OneKey
//
//  Created by PrashanthPukale on 8/6/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>

enum BLEOperationMode
{
    BLEOperationModeProx=113,
    BLEOperationModeKnock,
    BLEOperationModeProxKnock,
};

@interface OKUser : NSObject

@property (nonatomic,strong)NSString *fName;
@property (nonatomic,strong)NSString *lName;
@property (nonatomic,strong)NSString *idBitString;
@property (nonatomic,strong)NSString *potraitURLString;
@property (nonatomic,strong)NSString *titleString;
@property (nonatomic,strong)NSString *certpass;
@property (nonatomic,strong)NSData *pk12Data;



// User Settings .... Load from persistant store -- PP

@property (nonatomic) int                   requiredKnocksCount;
@property (nonatomic) int                   sensitivity;
@property (nonatomic) BOOL                  isAppDisabled;
@property (nonatomic) BOOL                  requiresScreenUnlock;
@property (nonatomic) enum BLEOperationMode opMode;

- (void)reloadSettings;
+ (OKUser*)sharedUser;
+ (void)initUserInfo:(NSString *)str;
- (NSData*)dataForId;
- (float)minimumRssi;

+ (void)logoutUser;
+ (BOOL)isLoggedIn;
+ (void)resumeSession;
+ (void)didLoginWithUserInfo:(NSString*)userInfo;

@end
