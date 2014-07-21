//
//  OKBeaconManager.h
//  OneKey
//
//  Created by PrashanthPukale on 7/16/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

extern NSString *BeaconIdentifier;


@interface OKBeaconManager : NSObject



+(OKBeaconManager*)sharedManager;

#pragma mark - Dummy Helper Methods
- (CLBeaconRegion*)regionToBeRanged;
#pragma mark End -

@end
