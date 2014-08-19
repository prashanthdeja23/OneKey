//
//  OKMotionManager.m
//  OneKey
//
//  Created by PrashanthPukale on 8/8/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKMotionManager.h"

#define Z_ACC_FOR_KNOCK 1.5f
#define IGNORE_ACC_INTERVAL 0.2                 // Once a peak ACC in Z is detected , ignore values for this interval of time.
#define MAX_INTERVAL_BETWEEN_KNOCKS 1.0         // MAX time interval in secs between knocks.

static OKMotionManager *sharedInstance=nil;

@implementation OKMotionManager

+ (OKMotionManager*)sharedManager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (float)absFloat:(float)num
{
    return num<0?num*-1.0:num;
}

- (void)startMotionManager
{
    
    [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
        
       // NSLog(@"z %f y %f x %f",accelerometerData.acceleration.z,accelerometerData.acceleration.y,accelerometerData.acceleration.x);
        
        float dampnedZAcc=[self absFloat:accelerometerData.acceleration.z]-(.90*[self absFloat:accelerometerData.acceleration.x])-(.90*[self absFloat:accelerometerData.acceleration.y]);
        
        if (dampnedZAcc > Z_ACC_FOR_KNOCK)
        {
           // NSLog(@"z %f y %f x %f",accelerometerData.acceleration.z,accelerometerData.acceleration.y,accelerometerData.acceleration.x);
            
            if (self.lastKnockTime)
            {
                NSTimeInterval interval=[[NSDate date] timeIntervalSinceDate:self.lastKnockTime];
                if (interval>MAX_INTERVAL_BETWEEN_KNOCKS)
                {
                    self.knockCounts=0;
                    self.lastKnockTime=nil;
                }
                else if (interval>IGNORE_ACC_INTERVAL)
                {
                    self.knockCounts++;
                    self.lastKnockTime=[NSDate date];
                }
                else
                {
                    //DO Nothing.
                }
            }
            else
            {
                self.lastKnockTime=[NSDate date];
                self.knockCounts=1;
            }
            
            if (self.knockCounts==self.requiredKnockCounts)
            {
                self.knockCounts=0;
                self.lastKnockTime=nil;
                
                if ([_delegate respondsToSelector:@selector(OKMotionManagerDetectedTap:)])
                {
                    [_delegate OKMotionManagerDetectedTap:self];
                }
            }
        }
        
    } ];
}

- (void)startMotionUpdates
{
    //if application mode is backgrounded we start locatio manager as well so that we can keep the app alive.
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        if (!self.locationManager)
        {
            _locationManager=[[CLLocationManager alloc] init];
            _locationManager.delegate=self;
            _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        }
        [self.locationManager startUpdatingLocation];
        
        if (!self.motionManager)
        {
            _motionManager=[[CMMotionManager alloc] init];
            
        }
        
        [self startMotionManager];
        
    }
    else
    {
        // Just start motion manager instead.
        if (!self.motionManager)
        {
            _motionManager=[[CMMotionManager alloc] init];
        }
        
       // [self startMotionManager];
    }
}

- (void)stopMotionUpdates
{
    [_locationManager stopUpdatingLocation];
    [_motionManager stopAccelerometerUpdates];
}

- (void)postLocalNotification:(NSString*)text
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.repeatInterval = NSDayCalendarUnit;
    [notification setAlertBody:text];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    [self postLocalNotification:@"Got location notification "];
    NSLog(@"Did Update location ");
}



@end
