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

@property (nonatomic,strong) CBPeripheral            *peripheral;
@property (nonatomic,strong) NSLock                     *rssiArrayLock;

- (OKBLEPeripheral*)initWithPeripheral:(CBPeripheral*)peripheralObj;

@end
