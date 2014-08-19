//
//  OKBLEScanner.h
//  OneKey
//
//  Created by PrashanthPukale on 7/18/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OKMotionManager.h"

@class OKBLEManager;

@protocol OKBLManagerDelegate <NSObject>

// UI Related
- (void)OKBLEManager:(OKBLEManager*)manager startedMonitoringPeripheral:(CBPeripheral*)peripheral;
- (void)OKBLEManager:(OKBLEManager *)manager stoppedMonitoringPeripheral:(CBPeripheral*)peripheral;
- (void)OKBLEManager:(OKBLEManager *)manager didOpenDoorForPeripheral:(CBPeripheral*)peripheral;

@end

enum BLEConnectionState
{
    BLEConnectionStateDown,
    BLEConnectionStateUP,
    BLEConnectionStateDiscovering,
    BLEConnectionStateConnecting,
    BLEConnectionStateConnected
};

@interface OKBLEManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate,OKMotionManagerDelegate>

@property (nonatomic)BOOL   isConnectedForBLE;
@property (nonatomic,weak) __weak id <OKBLManagerDelegate> delegate;
@property (nonatomic)enum BLEConnectionState connectionState;
@property (nonatomic) NSMutableArray            *intrestedBLEPeripherals;

+ (OKBLEManager *)sharedManager;

- (void)connectToPeripheral:(CBPeripheral*)peripheral;
- (void)startScanForDoors;
- (void)peripheral:(CBPeripheral*)peripheral writeToCharacterstic:(NSString*)charactersticUUID forServiceID:(NSString*)serviceID data:(NSData*)data;
- (NSData*)getDataToWrite;
- (void)disconnectPeripheral:(CBPeripheral*)peripheral;
- (void)stopDiscovery;
- (void)peripheralReadRssiValue:(CBPeripheral*)peripheral;

- (void)openDoorAtIndex:(int)index;

@end
