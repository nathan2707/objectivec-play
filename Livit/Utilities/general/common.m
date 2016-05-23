//
//  common.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "common.h"
#import "WelcomeView.h"
#import "PremiumView.h"
#import "NavigationController.h"

void LoginUser(id target)
{
	NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
	[target presentViewController:navigationController animated:YES completion:nil];
}

void ActionPremium(id target)

{
	PremiumView *premiumView = [[PremiumView alloc] init];
	premiumView.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[target presentViewController:premiumView animated:YES completion:nil];
}

void PostNotification(NSString *notification)

{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}
