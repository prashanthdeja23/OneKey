//
//  OKBLEPeripheral.h
//  OneKey
//
//  Created by PrashanthPukale on 8/5/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface OKBLEPeripheral : NSObject
{
    NSMutableArray                *rssiValues;
}

- (void)insertRssi:(NSNumber*)num;                  // This obj will store 50 last rssi objects and provides the Avg value to client
- (NSNumber*)avgRssi;

@property (nonatomic,strong) CBPeripheral             *cbPeripheral;
@property (nonatomic,strong) NSLock                     *rssiArrayLock;
@property (nonatomic,strong) NSDate                      *lastOpenedDate;
@property (nonatomic) BOOL                                isOpening;


- (OKBLEPeripheral*)initWithPeripheral:(CBPeripheral*)peripheralObj;
+ (NSString*)getServerIpForPeripheral:(CBPeripheral*)peripheralObj;
+ (int)getRssiThresholdForPeripheral:(CBPeripheral*)peripheral;
- (int)getMinRssiForSensitivity:(int)sensititvity;
- (float)timeSinceLastOpen;

@end
