//
//  OKMotionManager.m
//  OneKey
//
//  Created by PrashanthPukale on 8/8/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKMotionManager.h"
#import <AudioToolbox/AudioServices.h>

#define Z_ACC_FOR_KNOCK 1.5f
#define IGNORE_ACC_INTERVAL 0.1                 // Once a peak ACC in Z is detected , ignore values for this interval of time.
#define MAX_INTERVAL_BETWEEN_KNOCKS 1.5         // MAX time interval in secs between knocks.

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

+ (void)vibratePhone
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)startMotionManager
{
    OKUser *user=[OKUser sharedUser];
    
    [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
        
       // NSLog(@"z %f y %f x %f",accelerometerData.acceleration.z,accelerometerData.acceleration.y,accelerometerData.acceleration.x);
        
        float dampnedZAcc=fabs(accelerometerData.acceleration.z)-(.70*fabs(accelerometerData.acceleration.x))-(.70*fabs(accelerometerData.acceleration.y));
        float intervalSinceLastUpdate=0;
        
        if (self.lastUpdateTimeStamp>0)
        {
            intervalSinceLastUpdate=accelerometerData.timestamp-self.lastUpdateTimeStamp;
        }
        
        self.lastUpdateTimeStamp=accelerometerData.timestamp;
        
      //  NSLog(@"Inyterval %.2f",intervalSinceLastUpdate);
        
        if (dampnedZAcc > Z_ACC_FOR_KNOCK && user.requiredKnocksCount)
        {
           // NSLog(@"z %f y %f x %f : %f",accelerometerData.acceleration.z,accelerometerData.acceleration.y,accelerometerData.acceleration.x,dampnedZAcc);
            
           
            if (self.lastKnockTime)
            {
                NSTimeInterval interval=[[NSDate date] timeIntervalSinceDate:self.lastKnockTime];
                if (interval>MAX_INTERVAL_BETWEEN_KNOCKS)
                {
                    self.knockCounts=1;
                    self.lastKnockTime=[NSDate date];
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
            
            // NSLog(@"Knock %d required %d",self.knockCounts,self.requiredKnockCounts);
            if (self.knockCounts==user.requiredKnocksCount)
            {
                self.knockCounts=0;
                self.lastKnockTime=nil;
                self.lastUpdateTimeStamp=-1;
                
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
   // NSLog(@"Stop Motion Updates");
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
        
        [self startMotionManager];
    }

    
//    OKAVManager *avManager=[OKAVManager sharedManager];
//    if (![avManager playing])
//    {
//        [avManager startContinuesBackgroundAudio];
//    }
//    
//    
//    // Just start motion manager instead.
//    if (!self.motionManager)
//    {
//        _motionManager=[[CMMotionManager alloc] init];
//    }
//    [self startMotionManager];
    
}

- (void)stopMotionUpdates
{
   // NSLog(@"Stop Motion Updates");
    OKAVManager *avManager=[OKAVManager sharedManager];
    [avManager stopBackgroundAudio];
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
   // [self postLocalNotification:@"Got location notification "];
  //  NSLog(@"Did Update location ");
}



@end
