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
- (void)OKBLManagerDidUpdateState:(OKBLEManager*)manager;
- (void)OKBLManagerDidFailToConnect:(OKBLEManager*)manager;
@end

enum BLEConnectionState
{
    BLEConnectionStateDown,
    BLEConnectionStateUP,
    BLEConnectionStateDiscovering,
    BLEConnectionStateConnecting,
    BLEConnectionStateConnected
};

@interface OKBLEManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic)BOOL   isConnectedForBLE;
@property (nonatomic,weak) __weak id <OKBLManagerDelegate> delegate;
@property (nonatomic)enum BLEConnectionState connectionState;

+ (OKBLEManager *)sharedManager;
- (void)connectToPeripheralWithService:(NSArray*)serviceIds;


@end
