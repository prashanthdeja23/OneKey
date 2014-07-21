//
//  OKBeaconManager.m
//  OneKey
//
//  Created by PrashanthPukale on 7/16/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKBeaconManager.h"
#import "DataManager+FetchManager.h"
#import "Beacon.h"

NSString *BeaconIdentifier = @"com.DejaView.OneKey";

const  NSString *BEACON_NOTIFY_DID_ENTER=@"BEACON_NOTIFY_DID_ENTER";
const  NSString *BEACON_NOTIFY_DID_EXIT=@"BEACON_NOTIFY_DID_EXIT";
const  NSString *BEACON_NOTIFY_DID_CHANGE_RANGE=@"BEACON_NOTIFY_DID_CHANGE_RANGE";

static OKBeaconManager *_sharedManager=nil;

@class Beacon;

@implementation OKBeaconManager

#pragma mark - singleton Methods

+(void)initialize
{
    if (_sharedManager==nil)
    {
        _sharedManager=[[OKBeaconManager alloc] init];
    }
}

+(OKBeaconManager*)sharedManager
{
    return _sharedManager;
}

#pragma mark end

// A method to hard code region to ranged.
- (CLBeaconRegion*)regionToBeRanged
{
    NSString *proximityUUID=@"393FA29F-3D07-438B-8C30-5617BF000099";
    CLBeaconRegion *region=[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:proximityUUID] identifier:BeaconIdentifier];
    return region;
}

- (void)startMonitoringAllBeacons
{
//    DataManager *dManager=[DataManager sharedManager];
//    NSArray *allBeacons=[dManager getAllBeacons];
//    for (Beacon *beaconObj in allBeacons)
//    {
//        
//    }
}

@end
