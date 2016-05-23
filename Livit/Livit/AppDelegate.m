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
#import "Foursquare2.h"

@implementation AppDelegate
//static NSString *const kHNKDemoGooglePlacesAutocompleteApiKey = @"AIzaSyAfyalPB3lJGcL8JsgYvl-8WquhmRd4f0k";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse enableLocalDatastore];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Initialize Parse.
    [Parse setApplicationId:@"FKI3nzOow23ImzVMiK86hLuXS6FDLrxQsIpudWpc"
                  clientKey:@"d18LPzTxzuAAzQM56LaRWZzZWKHtC2BiJuNXyaes"];
    
    [Foursquare2 setupFoursquareWithClientId:@"W24T3GRWEDKEYYIBNAS4US35HKVOAE2DGMGUWIJ0OJZWRLD0"
                                      secret:@"CIP5GCEBKLZSSOBHQ0L4SURY2WOKJUYUUBECRQJ5A4S2GOB5"
                                 callbackURL:@"livit://"];
    
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
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController4,navController2, navController3,navController5,navController1, nil];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.selectedIndex = DEFAULT_TAB;
    
    navController1.navigationBar.barTintColor = [UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1];
    navController2.navigationBar.barTintColor = [UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1];
    navController3.navigationBar.barTintColor = [UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1];
    navController4.navigationBar.barTintColor = [UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1];
    navController5.navigationBar.barTintColor = [UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1];
    
    
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
    
    

    
    UIColor *backgroundColor = [UIColor colorWithRed:102/255.0 green:107/255.0 blue:102/255.0 alpha:1];
    
    // set the bar background color
    [[UITabBar appearance] setBackgroundImage:[AppDelegate imageFromColor:backgroundColor forSize:CGSizeMake(self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height) withCornerRadius:0]];
    
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // set the selected icon color
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    // Set the dark color to selected tab (the dimmed background)
    [[UITabBar appearance] setSelectionIndicatorImage:[AppDelegate imageFromColor:[UIColor colorWithRed:(255.f/255.f) green:(205.f/255.f) blue:(34.f/255.f) alpha:1] forSize:CGSizeMake(self.tabBarController.tabBar.frame.size.width/5, self.tabBarController.tabBar.frame.size.height) withCornerRadius:7]];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([[notificationPayload objectForKey:@"info"] isEqualToString:@"GroupsView"]){
        [self.window.rootViewController presentViewController:navController5 animated:YES completion:NULL];
        UITabBarItem *item = self.tabBarController.tabBar.items[3];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    } else if ([[notificationPayload objectForKey:@"info"] isEqualToString:@"GroupSettingsView"]){
        [self.window.rootViewController presentViewController:navController1 animated:YES completion:NULL];
        UITabBarItem *item = self.tabBarController.tabBar.items[4];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    } else if ([[notificationPayload objectForKey:@"info"] isEqualToString:@"InvitesView"]){
        [self.window.rootViewController presentViewController:navController2 animated:YES completion:NULL];
        UITabBarItem *item = self.tabBarController.tabBar.items[0];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow: 60.0*30];
    NSTimer *t = [[NSTimer alloc] initWithFireDate: d
                                          interval: 60.0*30
                                            target: self
                                          selector:@selector(sendNotification)
                                          userInfo:nil repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:t forMode: NSDefaultRunLoopMode];}

-(void)sendNotification{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSMutableArray *channels = [[NSMutableArray alloc]init];
    
    PFQuery *queryForHouses = [PFQuery queryWithClassName:@"Houses"];
    [queryForHouses whereKey:@"Members" equalTo:[PFUser currentUser].objectId];
    [queryForHouses findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError * error) {
        if (!error){
            for (PFObject *house in objects){
                [channels addObject:[@"h" stringByAppendingString:house.objectId]];
            }
            
        }
        PFQuery *queryForEvents = [PFQuery queryWithClassName:@"Events"];
        [queryForEvents whereKey:@"Identities" equalTo:[PFUser currentUser].objectId];
        [queryForEvents findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError * error) {
            if (!error){
                for (PFObject *event in objects){
                    [channels addObject:[@"h" stringByAppendingString:event.objectId]];
                }
                [currentInstallation setChannels:channels];
                if (currentInstallation.badge != 0) {
                    currentInstallation.badge = 0;
                    [currentInstallation saveEventually];
                }
            }
        }];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self locationManagerStart];
    [FBSDKAppEvents activateApp];
    PostNotification(NOTIFICATION_APP_STARTED);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSMutableArray *channels = [[NSMutableArray alloc]init];
    
    if ([PFUser currentUser]){
    PFQuery *queryForHouses = [PFQuery queryWithClassName:@"Houses"];
    [queryForHouses whereKey:@"Members" equalTo:[PFUser currentUser].objectId];
    [queryForHouses findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError * error) {
        if (!error){
            for (PFObject *house in objects){
                [channels addObject:[@"h" stringByAppendingString:house.objectId]];
            }
            
        }
        PFQuery *queryForEvents = [PFQuery queryWithClassName:@"Events"];
        [queryForEvents whereKey:@"Identities" equalTo:[PFUser currentUser].objectId];
        [queryForEvents findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError * error) {
            if (!error){
                for (PFObject *event in objects){
                    [channels addObject:[@"h" stringByAppendingString:event.objectId]];
                }
                 [currentInstallation setChannels:channels];
                if (currentInstallation.badge != 0) {
                    currentInstallation.badge = 0;
                    [currentInstallation saveEventually];
                }
            }
        }];
    }];
    }
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
    
    //return [Foursquare2 handleURL:url];
    
    if (url == [NSURL URLWithString:@"https://fb.me/392279564302271"]){
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData]) {
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken

{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    if ([PFUser currentUser].objectId != nil){
    currentInstallation[@"user"] = [PFUser currentUser].objectId;
    }
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error

{
    //NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo

{
    
    if ([[userInfo objectForKey:@"info"] isEqualToString:@"GroupsView"]){
        UITabBarItem *item = self.tabBarController.tabBar.items[3];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    } else if ([[userInfo objectForKey:@"info"] isEqualToString:@"GroupSettingsView"]){
        UITabBarItem *item = self.tabBarController.tabBar.items[4];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    } else if ([[userInfo objectForKey:@"info"] isEqualToString:@"InvitesView"]){
        UITabBarItem *item = self.tabBarController.tabBar.items[0];
        item.badgeValue = [NSString stringWithFormat:@"%i", (int)item.badgeValue.doubleValue + 1];
    }

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

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}




@end

