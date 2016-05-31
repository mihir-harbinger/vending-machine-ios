//
//  Machine.h
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Machine : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchOutlet;
- (IBAction)switchAction:(id)sender;
@property(nonatomic, retain) NSArray *myArray;
@property(nonatomic, retain) NSArray *cmdSequence;
@property(nonatomic, retain) NSNumber *counter;
@property(nonatomic, retain) NSNumber *cmdCounter;

@end
