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

-(void)connectToPeripheralWithService:(NSArray*)serviceIds
{
    self.connectOnUp=YES;
    self.serviceUUIDs=[self uuidArrayForStringArray:serviceIds];
    
    if (!_centralManager)
    {
        _centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    else if (self.isConnectedForBLE)
    {
        self.connectOnUp=NO;
        
        [self startDiscoveringPheripheralWithServiceID:self.serviceUUIDs];
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

- (void)stopDiscovery
{
    [self.centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //[central connectPeripheral:peripheral options:nil];
    NSLog(@" %@",peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([_delegate respondsToSelector:@selector(OKBLManager:didConnectToPeripheral:)])
    {
        [_delegate OKBLManager:self didConnectToPeripheral:peripheral];
    }
}

#pragma mark BLEScane End-

@end
