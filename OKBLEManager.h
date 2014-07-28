//
//  OKBLEScanner.h
//  OneKey
//
//  Created by PrashanthPukale on 7/18/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class OKBLEManager;

@protocol OKBLManagerDelegate <NSObject>
- (void)OKBLManager:(OKBLEManager*)manager didConnectToPeripheral:(CBPeripheral*)peripheralDevice;
- (void)OKBLManager:(OKBLEManager*)manager DidDiscoverDevice:(CBPeripheral*)peripheralDevice adData:(NSDictionary*)adData andRssi:(NSNumber*)rssi;
@end

enum BLEConnectionState
{
    BLEConnectionStateDown,
    BLEConnectionStateUP,
    BLEConnectionStateDiscovering,
    BLEConnectionStateConnecting,
    BLEConnectionStateConnected
};

@interface OKBLEManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic)BOOL   isConnectedForBLE;
@property (nonatomic,weak) __weak id <OKBLManagerDelegate> delegate;
@property (nonatomic)enum BLEConnectionState connectionState;

+ (OKBLEManager *)sharedManager;

- (void)connectToPeripheral:(CBPeripheral*)peripheral;
- (void)startScanForPeripheralWithServiceIds:(NSArray*)serviceIds;

@end
