//
//  CustomTabBar.m
//  BLE
//
//  Created by Mihir Karandikar on 5/16/16.
//  Copyright © 2016 NPP. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar
-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 100;
    
    return sizeThatFits;
}
@end
