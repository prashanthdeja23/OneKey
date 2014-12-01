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
#import "AFNetworking.h"

#define BLE_RX_UUID @"713D0002-503E-4C75-BA94-3148F18D941E"

#define BLE_SERVICE_UUID @"713D0000-503E-4C75-BA94-3148F18D941E"

//@"180D"

#define BLE_AD_SERVICE_UUID @"1082"
// // // @"1811"

#define CHARACTERSTIC_UUID @"713D0003-503E-4C75-BA94-3148F18D941E"
#define RSSI_PADDING 20

NSString *DID_OPEN_DOOR_NOTIFICATION=@"openDoor";
NSString *BLUETOOTh_STATE_CHANGED=@"BTTOFF";

float MinIntervalBetweenOpens=15.0;

@interface OKBLEManager ()

@property (nonatomic,strong) CBCentralManager   *centralManager;

@property (nonatomic,strong)NSArray             *serviceUUIDs;
@property (nonatomic,strong) NSString           *serviceToWrite;
@property (nonatomic,strong) NSString           *charactersticToWrite;
@property (nonatomic,strong) NSData             *dataToWrite;
@property (nonatomic,strong)CBPeripheral        *peripheralToWrite;
@property (nonatomic,strong)CBCharacteristic    *readCharacterstic; // RX

@property (nonatomic,weak)__weak OKMotionManager    *motionManager;
@property (nonatomic)BOOL                           isOpeningDoor;
@property (nonatomic)int                            readRssiAttemptCount;
@property (nonatomic)BOOL                           performDirtyWrite; // Write something to just initiate the disconnection  ... we will write bit values 0000000


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

- (NSError *)errorForCode:(int)errorCode
{
    return [NSError errorWithDomain:@"com.onekey.opendoor" code:errorCode userInfo:nil];
}

- (void)openDoorForPeripheral:(OKBLEPeripheral*)peripheral
{
    if (peripheral!=nil)
    {
        self.isOpeningDoor=YES;
        peripheral.isOpening=YES;
        
        OKUser *currectUser=[OKUser sharedUser];
        if (self.useHttp)
        {
            [self openDoorHttpForPeripheral:peripheral.cbPeripheral];
        }
        else
        {
            [self peripheral:peripheral.cbPeripheral writeToCharacterstic:CHARACTERSTIC_UUID forServiceID:BLE_SERVICE_UUID data:[currectUser dataForId]];
        }
    }
    else
    {
        self.isOpeningDoor=NO;
        if ([_delegate respondsToSelector:@selector(OKBLEManager:didFailToOpenWithError:)])
        {
            NSError *failedError=[self errorForCode:BLEDoorOpenErrorNoDoorInRange];
            [_delegate OKBLEManager:self didFailToOpenWithError:failedError];
        }
    }
    
}

- (void)openDoorAtIndex:(int)index
{
    OKBLEPeripheral *peripheralDevice=[self.intrestedBLEPeripherals objectAtIndex:index];
    if ([self canOpenPeripheral:peripheralDevice])
    {
        [self openDoorForPeripheral:peripheralDevice];
    }
}

- (void)openNearestDoor
{
    OKBLEPeripheral *nearestDoor=[self getNearestDoor];
   
    if (nearestDoor!=nil && [self canOpenPeripheral:nearestDoor])
    {
        [self openDoorForPeripheral:nearestDoor];
    }
    else
    {
        // No door is near enough to open.
        
        if (![self isInRange:nearestDoor])
        {
            // NSLog(@"No Door in proximity");
        }
        else if (![self minOpenIntervalElapsed:nearestDoor])
        {
           // NSLog(@"Opened recently ");
        }
    }
}

- (OKBLEPeripheral*)getNearestDoor
{
    OKBLEPeripheral *peripheralNearest=nil;
    float lowestRssi=-1000;
    
    for (OKBLEPeripheral *peripheral in self.intrestedBLEPeripherals)
    {
        if (lowestRssi<[[peripheral avgRssi] floatValue])
        {
            peripheralNearest=peripheral;
            lowestRssi=[[peripheral avgRssi] floatValue];
        }
    }
    
    return peripheralNearest;
}

#pragma mark - sec methods

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust,
                                 CFStringRef keyPassword)
{
    OSStatus securityError = errSecSuccess;
    
    
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { keyPassword };
    CFDictionaryRef optionsDictionary = NULL;
    
    /* Create a dictionary containing the passphrase if one
     was specified.  Otherwise, create an empty dictionary. */
    optionsDictionary = CFDictionaryCreate(
                                           NULL, keys,
                                           values, (keyPassword ? 1 : 0),
                                           NULL, NULL);  // 1
    
    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inPKCS12Data,
                                    optionsDictionary,
                                    &items);                    // 2
    
    
    //
    if (securityError == 0) {                                   // 3
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
                                             kSecImportItemIdentity);
        CFRetain(tempIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        
        CFRetain(tempTrust);
        *outTrust = (SecTrustRef)tempTrust;
    }
    
    if (optionsDictionary)                                      // 4
        CFRelease(optionsDictionary);
    
    if (items)
        CFRelease(items);
    
    return securityError;
}

#pragma mark - end

- (void)openDoorHttpForPeripheral:(CBPeripheral*)peripheral
{
    // Suppose to do a Http Post with the Id and the Beacon mac Address.
    NSString *serverIpString=[OKBLEPeripheral getServerIpForPeripheral:peripheral];
    if (serverIpString.length)
    {
        
        NSString *urlString=[NSString stringWithFormat:@"https://%@:2062/?op=loc",serverIpString];
        OKUser *loggedInUser=[OKUser sharedUser];
        
        NSDictionary *dictionaryForParams=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[loggedInUser idBitString],peripheral.name, nil] forKeys:[NSArray arrayWithObjects:@"id",@"beacon", nil] ];
        
        SecIdentityRef idRef=NULL;
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *reponseSerializer = [AFHTTPResponseSerializer serializer];
        reponseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        manager.responseSerializer=reponseSerializer;
        
        [self extractIdentity :(__bridge CFDataRef)(loggedInUser.pk12Data) :&idRef :loggedInUser.certpass];
        
        SecCertificateRef certificate = NULL;
        SecIdentityCopyCertificate (idRef, &certificate);
        
        const void *certs[] = {certificate};
        CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
        
        // create a credential from the certificate and ideneity, then reply to the challenge with the credential
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:idRef certificates:(__bridge NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
        
         manager.credential=credential;
        
        AFSecurityPolicy *secPolicy =[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        secPolicy.allowInvalidCertificates=YES;
        secPolicy.pinnedCertificates=[NSArray arrayWithObject:[self getRootCA]];
        secPolicy.validatesDomainName=NO;
        secPolicy.validatesCertificateChain=NO;
        manager.securityPolicy=secPolicy;
        
        int index=[self isAlreadyMonitoringPeripheral:peripheral];
        OKBLEPeripheral *okPeripheral=[self.intrestedBLEPeripherals objectAtIndex:index];
 
        [manager POST:urlString parameters:dictionaryForParams success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *responseString=operation.responseString;
             
             if (responseString!=nil && ![responseString isEqualToString:@"invalid"])
             {
                 if ([responseString hasPrefix:@"ok"])
                 {
                     [self postDidOpenNotificationForPeripheral:okPeripheral.cbPeripheral];
                     
                     if (index!=-1)
                     {
                         
                         okPeripheral.lastOpenedDate=[NSDate date];
                         [self playDoorOpenSound];
                         if ([_delegate respondsToSelector:@selector(OKBLEManager:didOpenDoorForPeripheral:)])
                         {
                             [_delegate OKBLEManager:self didOpenDoorForPeripheral:peripheral];
                         }
                     }
                 }
                 
                 okPeripheral.isOpening=NO;
             }
             else
             {
                 // Invalid login.
             }
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             // Error ..
             okPeripheral.isOpening=NO;
         }];
    }
}

- (OSStatus)extractIdentity:(CFDataRef)inP12Data :(SecIdentityRef*)identity :(NSString*)passPhrase
{
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = (__bridge CFStringRef)(passPhrase);
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}

- (BOOL)isInRange:(OKBLEPeripheral*)peripheral
{
    OKUser *currentUser=[OKUser sharedUser];
    int minRssi=[peripheral getMinRssiForSensitivity:currentUser.sensitivity];
    
    return abs([peripheral.avgRssi intValue]) <= minRssi;
}

- (BOOL)minOpenIntervalElapsed:(OKBLEPeripheral*)peripheral
{
    float timeSinceLastOpen=[peripheral timeSinceLastOpen];
    if (timeSinceLastOpen>MinIntervalBetweenOpens && !peripheral.isOpening)
    {
        return YES;
    }
    return NO;
}

- (BOOL)canOpenPeripheral:(OKBLEPeripheral *)peripheral
{
    if ([self isInRange:peripheral]&&[self minOpenIntervalElapsed:peripheral])
    {
        return YES;
    }
    return NO;
}

- (void)postDidOpenNotificationForPeripheral:(CBPeripheral*)peripheral
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_OPEN_DOOR_NOTIFICATION object:nil userInfo:@{@"peripheralName": peripheral.name}];
}

- (void)playDoorOpenSound
{
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/sms-received1.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
 
    
    AudioServicesPlaySystemSound(soundID);
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
        //[self startDiscoveringPheripheralWithServiceID:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLUETOOTh_STATE_CHANGED object:nil];
    }
    else
    {
        if (central.state==CBCentralManagerStatePoweredOff)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:BLUETOOTh_STATE_CHANGED object:nil];
        }
    }
}

- (BOOL)isBluetoothOn
{
    return _centralManager.state!=CBCentralManagerStatePoweredOff;
}

- (void)startDiscoveringPheripheralWithServiceID:(NSArray*)serviceUUIDs
{
    if (self.isConnectedForBLE)
    {
        NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

        
       // [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:scanOptions];
        [self.centralManager scanForPeripheralsWithServices:nil options:scanOptions];
    }
    else
    {
        [self throwNotConnectedError];
    }
}

- (void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)startScanForDoors
{
    if (!_centralManager)
    {
        self.useHttp=YES;
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
    [self.intrestedBLEPeripherals removeAllObjects];
    self.centralManager=nil;
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

#pragma mark BLEScane End-


#pragma mark - CB Delegate Methods

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
    
    if (error&&self.readRssiAttemptCount<5)
    {
        NSLog(@"Rssi Error");
         [self peripheralReadRssiValue:peripheral];
        return;
    }
    
    NSLog(@"Min :%f CRssi:%f %@",[peripheral.RSSI floatValue],[user minimumRssi],error);
    
    if (fabs([peripheral.RSSI floatValue]) <= [user minimumRssi])
    {
        
       [self discoverServices:[NSArray arrayWithObject:[self uuidForString:self.serviceToWrite]] forPheripheral:peripheral];
    }
    else
    {
        // Not in range ... alert the user ...
        self.performDirtyWrite=YES;
       // [self disconnectPeripheral:peripheral];
        [self discoverServices:[NSArray arrayWithObject:[self uuidForString:self.serviceToWrite]] forPheripheral:peripheral];
        [OKMotionManager vibratePhone];
        //[self postLocalNotification:@"door not in range"];;
        self.isOpeningDoor=NO;
        
        //Or force a disconnect with a dummy write ..
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
  //  [self discoverServices:[NSArray arrayWithObject:[self uuidForString:self.serviceToWrite]] forPheripheral:peripheral];
    
    self.readRssiAttemptCount=0;
    [self peripheralReadRssiValue:peripheral];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
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
    else
    {
        [self postLocalNotification:@"Failed to discover service"];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   // NSLog(@"Discovered characterstics ... %d",service.characteristics.count);
    if (!error)
    {
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
    else
    {
        [self postLocalNotification:@"Failed to discover characterstic"];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if ([peripheral.name rangeOfString:@"lock"].location!=NSNotFound)
    {
        // Name starts with LOCK.
        NSArray *splitString=[peripheral.name componentsSeparatedByString:@"-"];
        if (splitString.count == 2)
        {
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            {
                
                [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                [self startMotionManager];
               
            }
            else
            {
                NSString *rssiString=splitString[1];
                rssiString=[rssiString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (abs([RSSI intValue])<=[rssiString intValue])
                {
                    // Show device info .
                    
                    [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                    [self startMotionManager];
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
                        }
                        else
                        {
                            [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                            [self startMotionManager];
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
    
    else
    {
        // For peripherals using IPRssi format
        //[peripheral.name rangeOfString:@"lok"].location!=NSNotFound
        
        if (peripheral.name.length>=10)
        {
            int rssiThreshold=[OKBLEPeripheral getRssiThresholdForPeripheral:peripheral];
            if (rssiThreshold>=30&&rssiThreshold<=100)
            {
                
                // NSLog(@"Name is %@",peripheral.name);
                
                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                {
                    
                    [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                    [self startMotionManager];
                    
                }
                else
                {
                    int minRssi=[OKBLEPeripheral getRssiThresholdForPeripheral:peripheral];
                    
                    
                    if (abs([RSSI intValue])<=minRssi)
                    {
                        // Show device info .
                        [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                        [self startMotionManager];
                    }
                    else
                    {
                        // Remove peripheral from intrested devices ..
                        int indexForPeripheral=[self isAlreadyMonitoringPeripheral:peripheral];
                        if (indexForPeripheral!=-1)
                        {
                            OKBLEPeripheral *peripheralInfo=[self.intrestedBLEPeripherals objectAtIndex:indexForPeripheral];
                            if (abs([[peripheralInfo avgRssi] intValue])>=minRssi+RSSI_PADDING)
                            {
                                [self stopMonitoringPeripheral:peripheral];
                                //[self stopMotionManager];
                            }
                            else
                            {
                                [self startMonitoringPeripheral:peripheral withAdData:advertisementData andRssi:RSSI];
                                [self startMotionManager];
                            }
                        }
                        else
                        {
                            
                        }
                        
                    }
                }
                
            }
                       
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Do Nothing.. Opened the door.
    if ([[peripheral.identifier UUIDString] isEqualToString:[[self.peripheralToWrite identifier]UUIDString]])
    {
        if ([_delegate respondsToSelector:@selector(OKBLEManager:didOpenDoorForPeripheral:)])
        {
            [_delegate OKBLEManager:self didOpenDoorForPeripheral:self.peripheralToWrite];
        }
    }
    _isOpeningDoor=NO;
    [self stopMonitoringPeripheral:self.peripheralToWrite];
}

#pragma mark End CB Delegate Methods -

#pragma mark - peripheral Tasks

- (void)peripheral:(CBPeripheral*)peripheral writeToCharacterstic:(CBCharacteristic*)characterstic forService:(CBService*)service
{
    
    peripheral.delegate=self;
    
    NSData *dataToWrite=(self.performDirtyWrite)?[self getDirtyData]:[self getDataToWrite];
    
    self.performDirtyWrite=NO;
    
    [peripheral writeValue:dataToWrite forCharacteristic:characterstic type:CBCharacteristicWriteWithoutResponse];
    
    int index=[self isAlreadyMonitoringPeripheral:peripheral];
    if (index!=-1)
    {
        OKBLEPeripheral *okPeripheral = [self.intrestedBLEPeripherals objectAtIndex:index];
        okPeripheral.isOpening=NO;
    }
}

// Initiate write operation by discovering service -> characterstic and then performing the write on the characterstic
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

- (void)peripheralReadRssiValue:(CBPeripheral*)peripheral
{
    peripheral.delegate=self;
    self.readRssiAttemptCount++;
    [peripheral readRSSI];
}

- (int)isAlreadyMonitoringPeripheral:(CBPeripheral*)peripheral
{
    int index=0;
    for (OKBLEPeripheral *peripheralInfoObj in self.intrestedBLEPeripherals)
    {
        if ([[peripheralInfoObj.cbPeripheral identifier].UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            return index;
        }
        index++;
    }
    return -1;
}

// Intrested in the peripheral because its in Range.
- (void)startMonitoringPeripheral:(CBPeripheral*)peripheral withAdData:(NSDictionary*)adDataDictionary andRssi:(NSNumber*)rssi
{
    // Add if not added and inform the delegate about it .
    
    int indexForPeripheral=[self isAlreadyMonitoringPeripheral:peripheral];
    OKUser *currentUser = [OKUser sharedUser];
    
    if (indexForPeripheral!=-1)
    {
        OKBLEPeripheral *peripheralInfoObj=[self.intrestedBLEPeripherals objectAtIndex:indexForPeripheral];
        [peripheralInfoObj insertRssi:rssi];
        
        if (currentUser.opMode==BLEOperationModeProx)
        {
            if ([self canOpenPeripheral:peripheralInfoObj])
            {
                [self openDoorForPeripheral:peripheralInfoObj];
            }
        }
       
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

#pragma mark peripheral Tasks End -

#pragma mark - OKBLManagerDelegate Methods

- (void)restartScanning
{
    [_centralManager stopScan];
    self.centralManager=nil;
    [self startScanForDoors];
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
    //[self postLocalNotification:@"open door"];
    
    if (self.intrestedBLEPeripherals.count)
    {
        [self openNearestDoor];
    }
    
}

- (void)disableBLE
{
    [self.intrestedBLEPeripherals removeAllObjects];
    [self.centralManager stopScan];
    self.centralManager=nil;
}

#pragma mark End Ok Motion Manager -

- (NSData*)getDirtyData
{
    const NSString *dataBits=@"00000000";
    
    int             bitSize=8;
    
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
- (NSData*)getDataToWrite
{
    const NSString *dataBits=@"0010100001100101111000100000000010100"; //hard coded 37 bit Id
    
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

- (void)postLocalNotification:(NSString*)text
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.repeatInterval = NSDayCalendarUnit;
    [notification setAlertBody:text];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

- (NSData*)getRootCA
{
    NSData *myData = [[NSUserDefaults standardUserDefaults] objectForKey:@"CertData"];
    return myData;
}

@end
