//
//  Programmer.h
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Programmer : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *greeting;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatus;

@property (weak, nonatomic) IBOutlet UITabBarItem *programmerTab;

@end
