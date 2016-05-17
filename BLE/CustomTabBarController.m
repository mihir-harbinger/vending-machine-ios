//
//  CustomTabBarController.m
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import "CustomTabBarController.h"

@implementation CustomTabBarController
- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = 80;
    tabFrame.origin.y = self.view.frame.size.height - 80;
    self.tabBar.frame = tabFrame;
}
@end
