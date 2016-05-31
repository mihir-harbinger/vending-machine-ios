//
//  Machine.m
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import "Machine.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface Machine () <CBPeripheralManagerDelegate, UITextViewDelegate>

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      20

@implementation Machine



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _myArray = @[@"Green Tea", @"Black Coffee", @"Lemonade", @"Hot Water"];
    _cmdSequence = @[@"Dispensing Coffee...", @"Order served!"];
    _counter = 0, _cmdCounter = [NSNumber numberWithInt:99];
}


- (IBAction)switchAction:(id)sender {
    if(self.switchOutlet.on){
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:VM_SERVICE_UUID]] }];
        NSLog(@"self.peripheralManager powered on.");
    }
    else{
        [self.peripheralManager stopAdvertising];
        NSLog(@"self.peripheralManager powered off.");
    }
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:VM_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWriteWithoutResponse
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:VM_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
    
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    _counter = 0;
    [self sendCustomData];
}

-(void)sendCustomData{
    
    BOOL didSend = YES;
    
    while(didSend && [_counter intValue] < [_myArray count]){
        // Start sending
        NSLog(@"%@", [_myArray objectAtIndex:[_counter integerValue]]);
        
        
        // Get the data
        self.dataToSend = [[NSString stringWithFormat: @"ITEM %@", [_myArray objectAtIndex:[_counter integerValue]]] dataUsingEncoding:NSUTF8StringEncoding];
        
        // Reset the index
        self.sendDataIndex = 0;
        
        
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        NSLog(didSend ? @"YES" : @"NO");
        if(didSend){
            _counter = @([_counter intValue] + 1);
        }
        //[NSThread sleepForTimeInterval: 5.0];
    }
    
}

-(void)dispenseCoffee{
    
    BOOL didSend = YES;
    
    while(didSend && [_cmdCounter intValue] < [_cmdSequence count]){
        // Start sending
        NSLog(@"%@", [_cmdSequence objectAtIndex:[_cmdCounter integerValue]]);
        
        
        // Get the data
        self.dataToSend = [[NSString stringWithFormat: @"%@", [_cmdSequence objectAtIndex:[_cmdCounter integerValue]]] dataUsingEncoding:NSUTF8StringEncoding];
        
        // Reset the index
        self.sendDataIndex = 0;
        
        
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        NSLog(didSend ? @"YES" : @"NO");
        if(didSend){
            _cmdCounter = @([_cmdCounter intValue] + 1);
        }
        [NSThread sleepForTimeInterval: 3.0];
    }
}

-(void)declineOrder{
    
    BOOL didSend = YES;
    
    self.dataToSend = [[NSString stringWithFormat: @"Machine out of order"] dataUsingEncoding:NSUTF8StringEncoding];
    
    self.sendDataIndex = 0;
    
    NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
    
    // Can't be longer than 20 bytes
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    
    // Copy out the data we want
    NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
    
    // Send it
    didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
    NSLog(didSend ? @"YES" : @"NO");
    //[NSThread sleepForTimeInterval: 5.0];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

 //Processes write command received from a central.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
    CBATTRequest*       request = [requests  objectAtIndex: 0];
    NSData*             request_data = request.value;
    NSString *str = [[NSString alloc] initWithData:request_data encoding:NSUTF8StringEncoding ];
    CBCharacteristic*   write_char = request.characteristic;
    //CBCentral*            write_central = request.central;
    //NSUInteger            multi_message_offset = request.offset;
    
    // Face commands this PWR RX to advertise serno UUID?
    int total_write_requests = 0;
    if([ write_char.UUID isEqual: [CBUUID UUIDWithString: VM_CHARACTERISTIC_UUID]] )
    {
        // Read desired new_state data from central:
        unsigned char* new_state = (unsigned char*)[request_data   bytes];
        new_state = &new_state[0];
        NSLog(@"%@ incoming", str);
        NSLog(@"        - advertise serno UUID: %s", new_state ? "TRUE" : "FALSE" );
        
        if ([str containsString:@"REQ"]) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Incoming request"
                                          message:@"Do I have enough sugar, water, milk powder?"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Yes"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            _cmdCounter = 0;
                                            [self dispenseCoffee];
                                        }];
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"No"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           //Handel no, thanks button
                                           [self declineOrder];
                                       }];
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        // Select UUID that includes serno of PWR RX, for advertisements:
        
        ++total_write_requests;
    }
    
//    if( total_write_requests ){
//        [peripheral respondToRequest:request    withResult:CBATTErrorSuccess];  // result = success
//
//    }
//    else
//    {
//        NSLog(@"_no_write_request_FAULT !!");
//    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendCustomData];
    [self dispenseCoffee];
}


@end