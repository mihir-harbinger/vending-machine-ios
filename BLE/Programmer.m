//
//  Programmer.m
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import "Programmer.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface Programmer () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) IBOutlet UITextView   *textview;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

@end


@implementation Programmer

-(void)viewDidLoad{
    [super viewDidLoad];
    self.greeting.text = [NSString stringWithFormat: @"Hello, %@", [[UIDevice currentDevice] name]];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];

}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(_centralManager.state)
    {
        case CBCentralManagerStateResetting:
            stateString = @"Updating...";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"BLE not supported";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"BLE not allowed to use";
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth OFF";
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"Bluetooth ON";
            break;
        default:
            stateString = @"Bluetooth Status: Unknown";
            break;
    }
    if([stateString isEqualToString: @"Bluetooth ON"]){
        self.bluetoothStatus.textColor = [UIColor colorWithRed:(30/255.f) green:(144/255.f) blue:(255/255.f) alpha:1];
    }
    else{
        self.bluetoothStatus.textColor = [UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(250/255.f) alpha:1];
    }
    self.bluetoothStatus.text = stateString;
}
@end
