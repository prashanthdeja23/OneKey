//
//  OKDoorsViewController.m
//  OneKey
//
//  Created by PrashanthPukale on 7/22/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "OKDoorsViewController.h"
#import "OKDoorTableViewCell.h"
#import "OKUtility.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "OKBLEPeripheral.h"
#import "OKMotionManager.h"

@interface OKDoorsViewController ()
{
    IBOutlet UITableView        *doorsTableView;
    IBOutlet UIView             *headerView;
    IBOutlet UILabel            *noDoorsLabel;
    BOOL                        shouldRefresh;
}

@property (nonatomic,strong)OKBLEManager *bleManager;
//@property (nonatomic,strong)NSMutableArray *bleDevices;
@property (nonatomic) BOOL                  readRssi;

@end

@implementation OKDoorsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.readRssi=NO;
    shouldRefresh=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    shouldRefresh=YES;
    
}

//- (void)updateRssi
//{
//    if (self.readRssi)
//    {
//        OKBLEManager *manager=[OKBLEManager sharedManager];
//        for (CBPeripheral *peripheral in self.bleDevices)
//        {
//            [manager peripheralReadRssiValue:peripheral];
//        }
//        
//    }
//    [self performSelector:@selector(updateRssi) withObject:nil afterDelay:0.5];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bleManager=[OKBLEManager sharedManager];
    self.bleManager.delegate=self;
    self.bleManager.useHttp=YES;
    
    OKMotionManager *motionManager=[OKMotionManager sharedManager];
    [motionManager startMotionUpdates];
    
    //self.bleDevices=[NSMutableArray array];
    
    
    self.view.backgroundColor=[OKUtility colorFromHexString:@"1B96C1"];
    
    [self refreshBLEInfo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- ( NSArray*)dummyDoorsArray
{
    return @[@{@"name": @"Main Entrance", @"rssi":@"10 ft"},@{@"name": @"Emergency Exit", @"rssi":@"12 ft"},@{@"name": @"Server Room", @"rssi":@"18 ft"}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSDictionary *)dictionaryForPeripheral:(OKBLEPeripheral*)peripheralInfo
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:peripheralInfo.cbPeripheral.name forKey:@"name"];
    [dict setObject:[peripheralInfo avgRssi] forKey:@"rssi"];
    [dict setObject:[NSNumber numberWithInteger:peripheralInfo.cbPeripheral.state] forKey:@"state"];
    
    return dict;
}

#pragma mark - Table View Delegates

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view=nil;
//    
//    return view;
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Unlock Door;
    
    [self.bleManager openDoorAtIndex:(int)indexPath.row];
    
    //[manager peripheral:peripheralDevice.peripheral writeToCharacterstic:CHARACTERSTIC_UUID forServiceID:BLE_SERVICE_UUID data:[manager getDataToWrite]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.bleManager.intrestedBLEPeripherals.count?0:50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.bleManager.intrestedBLEPeripherals.count)
    {
        // DO Nothing.
        tableView.hidden=NO;
        noDoorsLabel.hidden=YES;
    }
    else
    {
        tableView.hidden=YES;
        noDoorsLabel.hidden=NO;
        
    }
    
    return self.bleManager.intrestedBLEPeripherals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"CellIdentifier";
    OKDoorTableViewCell *cell= (OKDoorTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSDictionary *doorInfo = [self dictionaryForPeripheral:[self.bleManager.intrestedBLEPeripherals objectAtIndex:indexPath.row]];
    
    if (cell==nil)
    {
        cell=[[OKDoorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.doorInfo=doorInfo;
    [cell display];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

//- (void)updatePeripheral:(CBPeripheral*)peripheral
//{
//    int index=0;
//    for (CBPeripheral *device in self.bleDevices)
//    {
//        if ([device.name isEqualToString:peripheral.name])
//            break;
//        index++;
//    }
//    
//    if (index<self.bleDevices.count)
//    {
//        //Found at index;
//        [self.bleDevices replaceObjectAtIndex:index withObject:peripheral];
//        // Refresh TableView;
//    }
//    else
//    {
//        [self.bleDevices addObject:peripheral];
//    }
//}

//- (void)removePeripheral:(CBPeripheral*)peripheral
//{
//    int index=0;
//    for (CBPeripheral *device in self.bleDevices)
//    {
//        if ([device.name isEqualToString:peripheral.name])
//            break;
//        index++;
//    }
//    
//     if (index<self.bleDevices.count)
//     {
//         [self.bleDevices removeObjectAtIndex:index];
//     }
//    [doorsTableView reloadData];
//}

#pragma mark End-

#pragma mark - BLEDelegate Methods

- (void)startLookingForDoors
{
    //NSArray *serviceIds=[NSArray arrayWithObject:BLE_SERVICE_UUID];
    [self.bleManager startScanForDoors];
}

- (void)OKBLManager:(OKBLEManager*)manager DidDiscoverDevice:(CBPeripheral*)peripheralDevice adData:(NSDictionary *)adData andRssi:(NSNumber *)rssi
{
   // NSLog(@"Name : %@",peripheralDevice.name);
    
//    if ([peripheralDevice.name rangeOfString:@"lock"].location!=NSNotFound)
//    {
//        // Name starts with LOCK.
//        NSArray *splitString=[peripheralDevice.name componentsSeparatedByString:@"-"];
//        if (splitString.count == 2)
//        {
//            NSString *rssiString=splitString[1];
//            rssiString=[rssiString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            
//            NSLog(@"Rssi %@",rssi);
//            
//            if ([rssi integerValue]<=[rssiString integerValue])
//            {
//                // Show device info .
//                
//                [self updatePeripheral:peripheralDevice];
//                [doorsTableView reloadData];
//                
//               // [self.bleManager connectToPeripheral:peripheralDevice];
//                
//            }
//        }
//        else
//        {
//            // Invalid Device. ignore it - pp
//        }
//    }
    [doorsTableView reloadData];
}

//- (void)OKBLManager:(OKBLEManager*)manager didConnectToPeripheral:(CBPeripheral*)peripheralDevice
//{
//    [self updatePeripheral:peripheralDevice];
//    
//    //refresh tableview
//}

//- (void)OKBLManager:(OKBLEManager*)manager didDisconnectPeripheral:(CBPeripheral*)peripheral;
//{
//    [self removePeripheral:peripheral];
//}

//- (void)OKBLManager:(OKBLEManager*)manager didUpdateRssiForPeripheral:(CBPeripheral*)peripheral error:(NSError*)error;
//{
//    if (!error)
//    {
//        [self updatePeripheral:peripheral];
//    }
//    else
//    {
//        // Error reading RSSI- PP
//    }
//    
//}
//- (void)OKBLManager:(OKBLEManager*)manager didWriteSuccessfullyForPeripheral:(CBPeripheral*)peripheral
//{
//    [manager disconnectPeripheral:peripheral];
//    doorsTableView.userInteractionEnabled=YES;
//    doorsTableView.alpha=1.0;
//    [self removePeripheral:peripheral];
//    [doorsTableView reloadData];
//    
//    [self startLookingForDoors];
//    
//}

- (void)refreshBLEInfo
{
    if (shouldRefresh)
    {
        [doorsTableView reloadData];
    }
    
    [self performSelector:@selector(refreshBLEInfo) withObject:nil afterDelay:0.5];
}


- (void)OKBLEManager:(OKBLEManager*)manager startedMonitoringPeripheral:(CBPeripheral*)peripheral
{
    [doorsTableView reloadData];
}

- (void)OKBLEManager:(OKBLEManager *)manager stoppedMonitoringPeripheral:(CBPeripheral*)peripheral
{
    [doorsTableView reloadData];
}

- (void)OKBLEManager:(OKBLEManager *)manager didOpenDoorForPeripheral:(CBPeripheral*)peripheral
{
    [doorsTableView reloadData];
}

#pragma mark End-

@end
