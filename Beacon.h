//
//  Beacon.h
//  OneKey
//
//  Created by PrashanthPukale on 7/16/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSString * beaconId;
@property (nonatomic, retain) NSString * beaconIdentifier;
@property (nonatomic, retain) NSNumber * beaconLatitude;
@property (nonatomic, retain) NSNumber * beaconLongitude;
@property (nonatomic, retain) NSString * beaconMACaddress;
@property (nonatomic, retain) NSString * beaconMajor;
@property (nonatomic, retain) NSNumber * beaconMaxDuration;
@property (nonatomic, retain) NSString * beaconMinor;
@property (nonatomic, retain) NSString * beaconName;
@property (nonatomic, retain) NSNumber * beaconSignalEntryTarget;
@property (nonatomic, retain) NSNumber * beaconSignalExitTarget;
@property (nonatomic, retain) NSNumber * beaconSquelch;
@property (nonatomic, retain) NSString * beaconuuid;

@end
