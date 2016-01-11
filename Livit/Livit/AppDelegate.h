//
//  AppDelegate.h
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HousesController.h"
#import "RecentView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import <CoreLocation/CoreLocation.h>
#import "GroupsView.h"
#import "CategoryChoiceController.h"
#import "BrowserViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong,nonatomic) HousesController *housesView;
@property (strong, nonatomic) RecentView *recentView;
@property (strong, nonatomic) PeopleView *peopleView;
@property (strong, nonatomic) SettingsView *settingsView;
@property (strong, nonatomic) GroupsView *groupsView;
@property (strong, nonatomic) CategoryChoiceController *cat;
@property (strong, nonatomic) BrowserViewController *browserView;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

