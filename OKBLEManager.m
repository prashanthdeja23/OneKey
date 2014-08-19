//
//  OKBLEScanner.m
//  OneKey
//
//  Created by PrashanthPukale on 7/18/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKBLEManager.h"
#import "OKUtility.h"
#import "OKBLEPeripheral.h"
#import "OKUser.h"

#define BLE_RX_UUID @"713D0002-503E-4C75-BA94-3148F18D941E"
#define BLE_SERVICE_UUID @"713D0000-503E-4C75-BA94-3148F18D941E" //@"180d" //
#define CHARACTERSTIC_UUID @"713D0003-503E-4C75-BA94-3148F18D941E"
#define RSSI_PADDING 10

@interface OKBLEManager ()

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong)NSArray *serviceUUIDs;
@property (nonatomic) BOOL connectOnUp;
@property (nonatomic) int updateInterval;
@property (nonatomic,strong) NSString *serviceToWrite;
@property (nonatomic,strong) NSString *charactersticToWrite;
@property (nonatomic,strong) NSData   *dataToWrite;
@property (nonatomic,strong)CBPeripheral    *peripheralToWrite;
@property (nonatomic,strong)CBCharacteristic *readCharacterstic;
@property (nonatomic)int    backgroundNotificationCounter;
@property (nonatomic)BOOL   isBackground;
@property (nonatomic,weak)__weak OKMotionManager    *motionManager;
@property (nonatomic)BOOL           isOpeningDoor;

@end



@implementation OKBLEManager

- (id)init
{
    if (self=[super init])
    {
        // Do Nothing For now - PP
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
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

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    //Do Notign..
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    self.isConnectedForBLE=(central.state>=CBCentralManagerStatePoweredOn);
  
    
    if (central.state==CBCentralManagerStatePoweredOn)
    {
        self.serviceUUIDs=[self uuidArrayForStringArray:[NSArray arrayWithObject:BLE_SERVICE_UUID]];
        [self startDiscoveringPheripheralWithServiceID:self.serviceUUIDs];
    }
}

- (void)startDiscoveringPheripheralWithServiceID:(NSArray*)serviceUUIDs
{
    if (self.isConnectedForBLE)
    {
        NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

        
        [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:scanOptions];
    }
    else
    {
        [self throwNotConnectedError];
    }
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)startScanForDoors
{
    if (!_centralManager)
    {

        // This will trgger the delegate call back to did update state .. and from there we start scanning ..
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        _centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:aQueue options:@{ CBCentralManagerOptionRestoreIdentifierKey:
                                                                                                    @"myCentralManagerIdentifier" }];
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   // NSLog(@"Discovered characterstics ... %d",service.characteristics.count);
    CBCharacteristic *charactersticToWrite=nil;
    for (CBCharacteristic *characterstic in service.characteristics)
    {
        if ([characterstic.UUID.UUIDString isEqualToString:self.charactersticToWrite])
        {
            charactersticToWrite=characterstic;
        }
        else if ([characterstic.UUID.UUIDString isEqualToString:BLE_RX_UUID])
        {
            self.readCharacterstic=characterstic;
        }
    }
    
    if (charactersticToWrite!=nil)
    {
        [self peripheral:peripheral writeToCharacterstic:charactersticToWrite forService:service];
    }
}

- (void)peripheral:(CBPeripheral*)peripheral writeToCharacterstic:(CBCharacteristic*)characterstic forService:(CBService*)service
{
    
    //[OKUtility printBytes:self.dataToWrite];
    peripheral.delegate=self;
    
    [peripheral writeValue:self.dataToWrite forCharacteristic:characterstic type:CBCharacteristicWriteWithoutResponse];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(disconnectPeripheral:) withObject:peripheral afterDelay:0.3];
    });
    
    
}

- (void)peripheral:(CBPeripheral*)peripheral writeToCharacterstic:(NSString*)charactersticUUID forServiceID:(NSString*)serviceID data:(NSData*)data
{
    
    self.dataToWrite=data;
    self.peripheralToWrite=peripheral;
    
//    CBUUID *uuid=[self uuidForString:serviceID];
    
    self.serviceToWrite=serviceID;
    self.charactersticToWrite=charactersticUUID;
    peripheral.delegate=self;
    [self.centralManager connectPeripheral:peripheral options:nil];
   // [self discoverServices:[NSArray arrayWithObject:uuid] forPheripheral:peripheral];
    
    
}
- (void)peripheral:(CBPeripheral*)peripheral discoverCharactersricsForService:(CBService *)service
{
    peripheral.delegate=self;
    [peripheral discoverCharacteristics:[NSArray arrayWithObjects:[self uuidForString:self.charactersticToWrite],[self uuidForString:BLE_RX_UUID], nil] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    CBService *serviceWrite=nil;
    for (CBService *service in peripheral.services)
    {
        
        if ([service.UUID.UUIDString isEqualToString:self.serviceToWrite])
        {
            serviceWrite=service;
            break;
        }
    }
    if (serviceWrite!=nil)
    {
        [self peripheral:peripheral discoverCharactersricsForService:serviceWrite];
    }
}

- (NSData*)getDataToWrite
{
    const NSString *dataBits=@"0010100001100101111000100000000010100";
    
    int             bitSize=37;
    
    int byteSize = (bitSize + 8 - 1) / 8;
    NSMutableData *dataBytes= [[NSMutableData alloc] initWithLength:byteSize];
    
    Byte x=0;
   
    for (int i=0;i<bitSize;i++)
    {
        int bytePosition=(i/8);
         [dataBytes getBytes:&x range:NSMakeRange(bytePosition,1)];
        if ([dataBits characterAtIndex:i]-'0')
        {
            x |= 1<<( 7-(i%8));
            
        }
        
        [dataBytes replaceBytesInRange:NSMakeRange(bytePosition,1) withBytes:&x length:1];
        
    }
    
    return dataBytes;
}

- (void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)peripheralReadRssiValue:(CBPeripheral*)peripheral
{
    peripheral.delegate=self;
    [peripheral readRSSI];
}

- (int)isAlreadyMonitoringPeripheral:(CBPeripheral*)peripheral
{
    int index=0;
    for (OKBLEPeripheral *peripheralInfoObj in self.intrestedBLEPeripherals)
    {
        if ([[peripheralInfoObj.peripheral identifier].UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            return index;
        }
        index++;
    }
    return -1;
}


// Intrested in the peripheral becauze its in Range.
- (void)startMonitoringPeripheral:(CBPeripheral*)peripheral withAdData:(NSDictionary*)adDataDictionary andRssi:(NSNumber*)rssi
{
    // Add if not added and inform the delegate about it .
    int indexForPeripheral=[self isAlreadyMonitoringPeripheral:peripheral];
    
    if (indexForPeripheral!=-1)
    {
        OKBLEPeripheral *peripheralInfoObj=[self.intrestedBLEPeripherals objectAtIndex:indexForPeripheral];
        [peripheralInfoObj insertRssi:rssi];

    }
    else
    {
        OKBLEPeripheral *peripheralObj = [[OKBLEPeripheral alloc] initWithPeripheral:peripheral];
        if (!self.intrestedBLEPeripherals)
        {
            self.intrestedBLEPeripherals=[NSMutableArray array];
        }
        
        [self.intrestedBLEPeripherals addObject:peripheralObj];
        [peripheralObj insertRssi:rssi];
        
        if ([_delegate respondsToSelector:@selector(OKBLEManager:startedMonitoringPeripheral:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [_delegate OKBLEManager:self startedMonitoringPeripheral:peripheral];
            });
        }
    }
}

// Not intrested in peripheral , may be out of range ..
- (void)stopMonitoringPeripheral:(CBPeripheral*)peripheral
{
    // remove if already monitoring and then inform the delegate about it.
    
     int indexForPeripheral=[self isAlreadyMonitoringPeripheral:peripheral];
    
    if (indexForPeripheral!=-1)
    {
        [self.intrestedBLEPeripherals removeObjectAtIndex:indexForPeripheral];
        
        if ([_delegate respondsToSelector:@selector(OKBLEManager:stoppedMonitoringPeripheral:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate OKBLEManager:self stoppedMonitoringPeripheral:peripheral];
            });
        }
    }
}


#pragma mark - OKBLManagerDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self disconnectPeripheral:peripheral];
    });
    
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if ([_delegate respondsToSelector:@selector(OKBLEManager:didOpenDoorForPeripheral:)])
                           {
                               [_delegate OKBLEManager:self didOpenDoorForPeripheral:peripheral];
                           }
                       });
    }
    
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    OKUser *user=[OKUser sharedUser];
    if (([peripheral.RSSI floatValue]<0)?([peripheral.RSSI floatValue]*-1.0):[peripheral.RSSI floatValue] <= [user minimumRssi])
    {
        NSLog(@"Min :%f CRssi:%f %@",[peripheral.RSSI floatValue],[user minimumRssi],error);
        
        [self discoverServices:[NSArray arrayWithObject:[self uuidForString:self.serviceToWrite]] forPheripheral:peripheral];
    }
    else
    {
        // Not in range ... alert the user ...
        [self disconnectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // DO nothing
    if (error)
    {
        NSLog(@"%@",error);
    }
    NSLog(@"Disconnected peripheral");
    self.isOpeningDoor=NO;
}

- (void)postLocalNotification:(NSString*)text
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.repeatInterval = NSDayCalendarUnit;
    [notification setAlertBody:text];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

- (void)restartScanning
{
    [_centralManager stopScan];
    self.centralManager=nil;
    [self startScanForDoors];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
//    {
//         NSLog(@"peripheral discovered %@",peripheral.name);
//    }

    if ([peripheral.name rangeOfString:@"lock"].location!=NSNotFound)
    {
        // Name starts with LOCK.
        NSArray *splitString=[peripheral.name componentsSeparatedByString:@"-"];
        if (splitString.count == 2)
        {
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            {
                [self startMotionManager];
                [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
            }
            else
            {
                NSString *rssiString=splitString[1];
                rssiString=[rssiString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                
                
                if (abs([RSSI intValue])<=[rssiString intValue])
                {
                    // Show device info .
                    
                    [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                    
                    
                }
                else
                {
                    // Remove peripheral from intrested devices ..
                    int indexForPeripheral=[self isAlreadyMonitoringPeripheral:peripheral];
                    if (indexForPeripheral!=-1)
                    {
                        OKBLEPeripheral *peripheralInfo=[self.intrestedBLEPeripherals objectAtIndex:indexForPeripheral];
                        if (abs([[peripheralInfo avgRssi] intValue])>=[rssiString integerValue]+RSSI_PADDING)
                        {
                            [self stopMonitoringPeripheral:peripheral];
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                [self stopMotionManager];
                            }
                        }
                        else
                        {
                            [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                [self startMotionManager];
                            }
                        }
                    }
                    else
                    {
                        
                    }
                    
                }
            }
 
        }
        else
        {
            // Invalid Device. ignore it - pp
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        
//        if ([_delegate respondsToSelector:@selector(OKBLManager:DidDiscoverDevice:adData:andRssi:)])
//        {
//            [_delegate OKBLManager:self DidDiscoverDevice:peripheral adData:advertisementData andRssi:RSSI];
//        }
//    });
   
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
     [self discoverServices:[NSArray arrayWithObject:[self uuidForString:self.serviceToWrite]] forPheripheral:peripheral];
   // [self peripheralReadRssiValue:peripheral];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([_delegate respondsToSelector:@selector(OKBLManager:didConnectToPeripheral:)])
//        {
//            [_delegate OKBLManager:self didConnectToPeripheral:peripheral];
//        }
//    });
    
   
}

- (void)openDoorForPeripheral:(CBPeripheral*)peripheral
{
    self.isOpeningDoor=YES;
    OKUser *currectUser=[OKUser sharedUser];
    [self peripheral:peripheral writeToCharacterstic:CHARACTERSTIC_UUID forServiceID:BLE_SERVICE_UUID data:[currectUser dataForId]];
}

- (void)openDoorAtIndex:(int)index
{
    OKBLEPeripheral *peripheralDevice=[self.intrestedBLEPeripherals objectAtIndex:index];
    [self openDoorForPeripheral:peripheralDevice.peripheral];
}

#pragma mark - OKMotionManager

// Used to detect user knock/tap

- (void)startMotionManager
{
    if (!self.motionManager)
    {
        self.motionManager=[OKMotionManager sharedManager];
        self.motionManager.delegate=self;
    }
    OKUser *loggedInUser=[OKUser sharedUser];
    self.motionManager.requiredKnockCounts=loggedInUser.requiredKnocksCount;
    [self.motionManager startMotionUpdates];
}

- (void)stopMotionManager
{
    if (!self.motionManager)
    {
        self.motionManager=[OKMotionManager sharedManager];
    }
    [self.motionManager stopMotionUpdates];
}

- (void)OKMotionManagerDetectedTap:(OKMotionManager*)manager
{
    if (!_isOpeningDoor)
    {
        [manager stopMotionUpdates];
        
        if (self.intrestedBLEPeripherals.count)
        {
            [self openDoorAtIndex:0];
        }
    }
    
}


@end
