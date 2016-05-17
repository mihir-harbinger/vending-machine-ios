//
//  FirstViewController.m
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)JumpToSecondTab:(id)sender {
    [(UITabBarController *) self.tabBarController setSelectedIndex:1];
}
@end
