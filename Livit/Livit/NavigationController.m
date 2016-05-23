//
//  NavigationController.m
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.navigationBar.translucent = NO;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
