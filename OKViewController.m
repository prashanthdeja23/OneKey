//
//  OKViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/15/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKViewController.h"
#import "OKBeaconManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "OKBLEManager.h"

@interface OKViewController ()
{
    IBOutlet UILabel    *proximityInfoLabel;
}

@property (nonatomic,strong) CLLocationManager  *locationManager;
@property (nonatomic,strong)OKBLEManager *manager;
@end

@implementation OKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.locationManager=[[CLLocationManager alloc]init];
    self.locationManager.delegate=self;
    
    _manager=[OKBLEManager sharedManager];
    _manager.delegate=self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSString *serviceUUID=;
//    [_manager connectToPeripheralWithService:[NSArray arrayWithObject:serviceUUID]];
   // [_locationManager startRangingBeaconsInRegion:[[OKBeaconManager sharedManager] regionToBeRanged]];
    
}

- (void)OKBLManager:(OKBLEManager*)manager didConnectToPeripheral:(CBPeripheral*)peripheralDevice
{
    proximityInfoLabel.text=peripheralDevice.name;
}

//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    [central scanForPeripheralsWithServices:nil options:nil];
//}

//- (void)centralManager:(CBCentralManager *)central
// didDiscoverPeripheral:(CBPeripheral *)peripheral
//     advertisementData:(NSDictionary *)advertisementData
//                  RSSI:(NSNumber *)RSSI
//{
//    
//    NSLog(@"Discovered %@", peripheral.name);
//    proximityInfoLabel.text=[NSString stringWithFormat:@"%@:%@",peripheral.name,RSSI];
//    
//}

//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//{
//    /*
//     CoreLocation will call this delegate method at 1 Hz with updated range information.
//     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
//     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
//     use a set instead of an array.
//     */
//    for (CLBeacon *aBeacon in beacons)
//    {
//        if (aBeacon.proximity == CLProximityImmediate)
//        {
//            // Open the Door if you have permission.
//            proximityInfoLabel.text=@"Do you want to open the door?";
//            proximityInfoLabel.textColor=[UIColor greenColor];
//        }
//        else
//        {
//            // Your are not close enough.
//            proximityInfoLabel.text=@"No doors in range";
//            proximityInfoLabel.textColor=[UIColor redColor];
//        }
//    }
//}

@end
