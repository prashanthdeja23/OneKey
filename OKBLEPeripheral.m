//
//  OKBLEPeripheral.m
//  OneKey
//
//  Created by PrashanthPukale on 8/5/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKBLEPeripheral.h"
#define MAX_RSSI 50                 // MAX Rssi Being monitored.

@implementation OKBLEPeripheral

- (OKBLEPeripheral*)initWithPeripheral:(CBPeripheral*)peripheralObj
{
    if (self=[super init])
    {
        self.peripheral=peripheralObj;
        rssiValues=[NSMutableArray arrayWithCapacity:MAX_RSSI];
        self.rssiArrayLock=[[NSLock alloc] init];
    }
    return self;
}

- (void)insertRssi:(NSNumber*)num
{
    if (self.peripheral)
    {
        [rssiValues insertObject:num atIndex:0];
        if ([rssiValues count] == MAX_RSSI)
        {
            [self.rssiArrayLock lock];
            [rssiValues removeLastObject];
            [self.rssiArrayLock unlock];
        }
    }
    else
    {
        [self.rssiArrayLock lock];
        rssiValues=nil;         // If the peripheral got DisConn or something , dont do anythign on it.
        [self.rssiArrayLock unlock];
    }
}

- (NSNumber*)avgRssi
{
    float avg=0;
    [self.rssiArrayLock lock];
    NSArray *tempArray=[NSArray arrayWithArray:rssiValues];
    [self.rssiArrayLock unlock];
    
    for (NSNumber *num in tempArray)
    {
        avg+=[num floatValue];
    }
    if (self.peripheral)
    {
        return [NSNumber numberWithFloat:((avg*1.0)/[tempArray count])];
    }
    rssiValues=nil;
    return nil;
}

@end
