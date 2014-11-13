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
        self.cbPeripheral=peripheralObj;
        rssiValues=[NSMutableArray arrayWithCapacity:MAX_RSSI];
        self.rssiArrayLock=[[NSLock alloc] init];
        self.lastOpenedDate=[NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

- (void)insertRssi:(NSNumber*)num
{
    if (self.cbPeripheral)
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
    if (self.cbPeripheral)
    {
        return [NSNumber numberWithFloat:((avg*1.0)/[tempArray count])];
    }
    rssiValues=nil;
    return nil;
}

+ (NSString*)getServerIpForPeripheralName:(NSString*)peripheralName
{
   const char *bytes=[peripheralName UTF8String];
    char outBytes[5]={0,0,0,0,'\n'};
    
    for (int i =0; i<5; i++)
    {
        char xByte=bytes[i];
        char yByte=bytes[i+1];
        
        outBytes[i]=((xByte<<1)|(yByte&0x80));
    }
    return [NSString stringWithFormat:@"%s",outBytes];
}

+ (NSString*)getServerIpForPeripheral:(CBPeripheral*)peripheralObj
{
    NSString *name=peripheralObj.name;
    
    // Code to test name decoding.
   // name=@"AC11185A41GOOG01";
    
    NSString *ipAddressString=@"";
    
    if (name.length>=10)
    {
        NSString *substring=[name substringToIndex:8];
    
        int index=4;
        while (index!=0)
        {
            
         NSRange subsRange;
         subsRange.location=(4-index)*2;
         subsRange.length=2;
            
        NSString *subStringIp=[substring substringWithRange:subsRange];
           
        ipAddressString=[ipAddressString stringByAppendingFormat:@"%d",(int)strtol([subStringIp UTF8String], NULL, 16)];
            
            if (index!=1)
            {
                ipAddressString=[ipAddressString stringByAppendingString:@"."];
            }
            else
            {
                break;
            }
            index--;
           // printf("%x \n",mask);
        }
    }
    
    return ipAddressString;
}

+ (int)getRssiThresholdForPeripheral:(CBPeripheral*)peripheral
{
    NSString *name=peripheral.name;
    if (name.length>=10)
    {
        NSString *rssiSubstring=[name substringFromIndex:8];
        long rssiDec=strtol([rssiSubstring UTF8String], NULL, 16);
        return (int)rssiDec;
    }
    return 0;
}

- (int)getMinRssiForSensitivity:(int)sensititvity
{
    int rssiThreshhold=[OKBLEPeripheral getRssiThresholdForPeripheral:self.cbPeripheral];
    return rssiThreshhold +((2- sensititvity)*5);
}

- (float)timeSinceLastOpen
{
    return [[NSDate date] timeIntervalSinceDate:self.lastOpenedDate];
}

@end
