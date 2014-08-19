//
//  OKMotionManager.h
//  OneKey
//
//  Created by PrashanthPukale on 8/8/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@class OKMotionManager;

@protocol OKMotionManagerDelegate <NSObject>
- (void)OKMotionManagerDetectedTap:(OKMotionManager*)manager;
@end

@interface OKMotionManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CMMotionManager    *motionManager;
@property (nonatomic,weak) __weak   id<OKMotionManagerDelegate> delegate;
@property (nonatomic) int           knockCounts;
@property (nonatomic) int           requiredKnockCounts;
@property (nonatomic,strong) NSDate        *lastKnockTime;

- (void)startMotionUpdates;
- (void)stopMotionUpdates;
+ (OKMotionManager*)sharedManager;

@end
