//
//  AppDelegate.m
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppConstant.h"
#import "NavigationController.h"
#import "common.h"
#import <Bolts/Bolts.h>

@implementation AppDelegate
static NSString *const kHNKDemoGooglePlacesAutocompleteApiKey = @"AIzaSyAfyalPB3lJGcL8JsgYvl-8WquhmRd4f0k";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse enableLocalDatastore];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Initialize Parse.
    [Parse setApplicationId:@"FKI3nzOow23ImzVMiK86hLuXS6FDLrxQsIpudWpc"
                  clientKey:@"d18LPzTxzuAAzQM56LaRWZzZWKHtC2BiJuNXyaes"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:nil];
    
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefsFile" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    [PFImageView class];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.recentView = [[RecentView alloc] initWithNibName:@"RecentView" bundle:nil];
    self.settingsView = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];
    self.housesView = [[HousesController alloc]initWithNibName:@"HousesController" bundle:nil];
    self.cat = [[CategoryChoiceController alloc]initWithNibName:@"CategoryChoiceController" bundle:nil];
    self.browserView = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.recentView];
    NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.settingsView];
    NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.cat];
    NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.browserView];
    NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.housesView];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController4,navController1, navController3,navController5,navController2, nil];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.selectedIndex = DEFAULT_TAB;
    
    navController1.navigationBar.barTintColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    navController2.navigationBar.barTintColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    navController3.navigationBar.barTintColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    navController4.navigationBar.barTintColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    navController5.navigationBar.barTintColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    
    [navController1.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [navController2.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [navController3.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [navController4.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [navController5.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [navController1.navigationBar setTintColor:[UIColor whiteColor]];
    [navController2.navigationBar setTintColor:[UIColor whiteColor]];
    [navController3.navigationBar setTintColor:[UIColor whiteColor]];
    [navController4.navigationBar setTintColor:[UIColor whiteColor]];
    [navController5.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self locationManagerStart];
    [FBSDKAppEvents activateApp];
    PostNotification(NOTIFICATION_APP_STARTED);
}

#pragma mark - Facebook responses

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
#warning read that
    // Follow tutorials to create an applink url and register it on facebook.
    // Particularly: check if the invited facebook user is able to install the app.
    // Additional feature: use referal components in the URL to invite the user to join specific events.
    
    if (url == [NSURL URLWithString:@"https://fb.me/392279564302271"]){
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData]) {
        // this is an applink url, handle it here
        NSURL *targetUrl = [parsedUrl targetURL];
        [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                    message:[targetUrl absoluteString]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    }
    	return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //[PFPush handlePush:userInfo];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self performSelector:@selector(refreshRecentView) withObject:nil afterDelay:4.0];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshRecentView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.recentView loadRecents];
}

#pragma mark - Location manager methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self.coordinate = newLocation.coordinate;
    
    
    
    PFUser *user = [PFUser currentUser];
    
    
    NSNumber *lat = [NSNumber numberWithDouble:self.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:self.coordinate.longitude];
    NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
    //PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:newLocation];
    user[PF_USER_POSITION] = userLocation;
    // [user setValue:currentPoint forKey:@"geopoint"];
    // user[PF_USER_POINT] = currentPoint;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error saving location");
        }
        else{
            NSLog(@"Updated Location.");
            [manager stopUpdatingLocation];
        }
    }];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}






@end
