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

#define UI_DEMO 1
#define BLE_SERVICE_UUID @"713D0000-503E-4C75-BA94-3148F18D941E"


@interface OKDoorsViewController ()
{
    IBOutlet UITableView        *doorsTableView;
}

@property (nonatomic,strong)OKBLEManager *bleManager;
@property (nonatomic,strong)NSMutableArray *bleDevices;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_DEMO)
    {
        self.bleDevices=[NSMutableArray arrayWithArray:[self dummyDoorsArray]];
    }
    else
    {
        self.bleManager=[OKBLEManager sharedManager];
        self.bleManager.delegate=self;
        
        self.bleDevices=[NSMutableArray array];
        [self startLookingForDoors];
    }
   
    
    self.view.backgroundColor=[OKUtility colorFromHexString:@"1B96C1"];
    
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
- (NSDictionary *)dictionaryForPeripheral:(CBPeripheral*)peripheral
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:peripheral.name forKey:@"name"];
    [dict setObject:(!peripheral.RSSI)?[NSNumber numberWithInt:0]:peripheral.RSSI forKey:@"rssi"];
    
    return dict;
}

#pragma mark - Table View Delegates

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=nil;
    if (self.bleDevices.count)
    {
        // DO Nothing.
    }
    else
    {
        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        view.backgroundColor=[UIColor clearColor];
        UILabel *title=[[UILabel alloc] initWithFrame:view.bounds];
        [view addSubview:title];
        title.text=@"  Scanning for doors ...";
        title.font=[UIFont boldSystemFontOfSize:18];
        title.textColor=[UIColor whiteColor];
        
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.bleDevices.count?0:50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bleDevices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"CellIdentifier";
    OKDoorTableViewCell *cell= (OKDoorTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSDictionary *doorInfo=[self.bleDevices objectAtIndex:indexPath.row];
    
    if (cell==nil)
    {
        cell=[[OKDoorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.doorInfo=doorInfo;
    [cell display];
    
    return cell;
}

- (void)addDeviceIfNotYet:(CBPeripheral*)peripheral
{
    int index=0;
    for (CBPeripheral *device in self.bleDevices)
    {
        if ([device.name isEqualToString:peripheral.name])
            break;
        index++;
    }
    if (index<self.bleDevices.count)
    {
        //Found at index;
        [self.bleDevices replaceObjectAtIndex:index withObject:peripheral];
        // Refresh TableView;
    }
    else
    {
        [self.bleDevices addObject:peripheral];
    }
}

- (void)removePeripheral:(CBPeripheral*)peripheral
{
    int index=0;
    for (CBPeripheral *device in self.bleDevices)
    {
        if ([device.name isEqualToString:peripheral.name])
            break;
        index++;
    }
    
     if (index<self.bleDevices.count)
     {
         [self.bleDevices removeObjectAtIndex:index];
     }
}

#pragma mark End-

#pragma mark - BLEDelegate Methods

- (void)startLookingForDoors
{
    NSArray *serviceIds=[NSArray arrayWithObject:BLE_SERVICE_UUID];
    [self.bleManager startScanForPeripheralWithServiceIds:serviceIds];
}

- (void)OKBLManager:(OKBLEManager*)manager DidDiscoverDevice:(CBPeripheral*)peripheralDevice adData:(NSDictionary *)adData andRssi:(NSNumber *)rssi
{
    NSLog(@"Name : %@",peripheralDevice.name);
    
    if ([peripheralDevice.name rangeOfString:@"lock"].location!=NSNotFound)
    {
        // Name starts with LOCK.
        NSArray *splitString=[peripheralDevice.name componentsSeparatedByString:@"-"];
        if (splitString.count==2)
        {
            NSString *rssiString=splitString[1];
            rssiString=[rssiString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([rssi integerValue]<=[rssiString integerValue])
            {
                // Show device and start conecting .
                [self addDeviceIfNotYet:peripheralDevice];
                [doorsTableView reloadData];
                
                [self.bleManager connectToPeripheral:peripheralDevice];
                NSLog(@"Rssi %@",peripheralDevice.RSSI);
            }
        }
        else
        {
            // Invalid Device. ignore it - pp
        }
    }
}

- (void)OKBLManager:(OKBLEManager*)manager didConnectToPeripheral:(CBPeripheral*)peripheralDevice
{
    [self addDeviceIfNotYet:peripheralDevice];
    //refresh tableview
}

#pragma mark End-

@end
