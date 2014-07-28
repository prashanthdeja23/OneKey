//
//  OKBLEScanner.m
//  OneKey
//
//  Created by PrashanthPukale on 7/18/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKBLEManager.h"

@interface OKBLEManager ()

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong)NSArray *serviceUUIDs;
@property (nonatomic) BOOL connectOnUp;
@property (nonatomic) int updateInterval;

@end

@implementation OKBLEManager

- (id)init
{
    if (self=[super init])
    {
        // Do Nothing For now - PP
        
    }
    
    return self;
}

+ (OKBLEManager *)sharedManager
{
    static id scanner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scanner = [[self alloc] init];
    });
    
    return scanner;
}

- (void)throwNotConnectedError
{
    // Post a notification saying we have lost connection.
}

- (CBUUID*)uuidForString:(NSString*)stringID
{
    return [CBUUID UUIDWithString:stringID];
}

- (NSArray*)uuidArrayForStringArray:(NSArray*)stringArray
{
    NSMutableArray *array=[NSMutableArray array];
    
    for (NSString *str in stringArray)
    {
        CBUUID *uuid=[self uuidForString:str];
        if (uuid!=nil)
        {
            [array addObject:uuid];
        }
        
    }
    
    return array;
}

#pragma mark - BLEScan Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    self.isConnectedForBLE=(central.state>=CBCentralManagerStatePoweredOn);
    
    if (_isConnectedForBLE)
    {
        self.connectionState=BLEConnectionStateUP;
    }
}


- (void)startDiscoveringPheripheralWithServiceID:(NSArray*)serviceUUIDs
{
    if (self.isConnectedForBLE)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    else
    {
        [self throwNotConnectedError];
    }
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //[central connectPeripheral:peripheral options:nil];
    if ([_delegate respondsToSelector:@selector(OKBLManager:DidDiscoverDevice:adData:andRssi:)])
    {
        [_delegate OKBLManager:self DidDiscoverDevice:peripheral adData:advertisementData andRssi:RSSI];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([_delegate respondsToSelector:@selector(OKBLManager:didConnectToPeripheral:)])
    {
        [_delegate OKBLManager:self didConnectToPeripheral:peripheral];
    }
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)startScanForPeripheralWithServiceIds:(NSArray*)serviceIds
{
    if (!_centralManager)
    {
        _centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    self.serviceUUIDs=[self uuidArrayForStringArray:serviceIds];
    if (self.isConnectedForBLE )
    {
        [self startDiscoveringPheripheralWithServiceID:self.serviceUUIDs];
    }
    else
    {
        [self performSelector:@selector(startDiscoveringPheripheralWithServiceID:) withObject:self.serviceUUIDs afterDelay:2.0];
    }
    
}

- (void)discoverServices:(NSArray*)serviceUUIDs forPheripheral:(CBPeripheral*)peripheral
{
    peripheral.delegate=self;
    [peripheral discoverServices:serviceUUIDs];
}
- (void)stopDiscovery
{
    [self.centralManager stopScan];
}

#pragma mark BLEScane End-

#pragma mark - peripheral services mehods

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    // DId update peripheral..
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
   
}
@end
