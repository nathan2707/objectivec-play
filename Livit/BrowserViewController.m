//
//  BrowserViewController.m
//  Livit
//
//  Created by Nathan on 1/4/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "BrowserViewController.h"
#import "BrowserCell.h"
#import "TableHeader.h"
#import "ProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import "ProfileView.h"
#import "GroupsView.h"
#import "AppConstant.h"
#import "myButton.h"
#import "GroupSettingsView.h"
#import "AppDelegate.h"
#import "common.h"
#import "myTap.h"
#import <MapKit/MapKit.h>
#import "push.h"

//@import GoogleMaps;

@interface BrowserViewController ()
{
    NSMutableArray *events;
    NSMutableArray *houses;
    NSMutableArray *connectionsPerEvent;
    NSMutableArray *usersPerEvent;
    NSMutableArray *usersInvitedOrRequesting;
    UIRefreshControl *refreshControl;
    NSInteger numero;
    BOOL oneFinished;
    BOOL justOnce;
    int index;
    NSMutableArray *myHouses;
    NSMutableArray *imageviews;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *noEventsView;

@end

@implementation BrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"Mountains"]];
        self.tabBarItem.title = @"Explore";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([PFUser currentUser] == nil)
    {
        LoginUser(self);
    }
   // [GMSServices provideAPIKey:@"AIzaSyCMdkKlurqOvobVq2GHf5iXmTi4eliXVac"];
    self.title = @"Explore";
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.showsScopeBar = YES;
    events = [[NSMutableArray alloc]init];
    usersInvitedOrRequesting = [[NSMutableArray alloc]init];
    connectionsPerEvent = [[NSMutableArray alloc]init];
    usersPerEvent = [[NSMutableArray alloc]init];
    houses = [[NSMutableArray alloc]init];
    imageviews = [[NSMutableArray alloc]init];
    [self loadEvents:0];
    [self loadMyHouses];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionSearch)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    PFUser *user = [PFUser currentUser];
    if (user[@"PicURL"] != nil){
    self.searchBar.scopeButtonTitles = @[@"Around me",@"Preferences",@"Circles", @"Friends"];
    } else {
        self.searchBar.scopeButtonTitles = @[@"Around me",@"Preferences",@"Circles"];
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"BrowserCell" bundle:nil] forCellReuseIdentifier:@"BrowserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"TableHeader"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(decideWhatToLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
}




-(void)decideWhatToLoad{
    switch (numero) {
        case 0:
            [self loadEvents:numero];
            break;
        case 1:
            [self loadEvents:numero];
            break;
        case 2:
            [self loadEventsWithHouses];
            break;
        case 3:
            [self loadEventsWithFriends];
            break;
        default:
            break;
    }
}

-(void)actionSearch{
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.scrollsToTop = YES;
}

-(void)loadEvents:(NSInteger)selected{
    oneFinished = NO;
    [events removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    //[query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"radiusMax"] == nil || [[NSUserDefaults standardUserDefaults]valueForKey:@"Category2"] == nil){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Oups"
                                                                       message:@"You haven't set your exploration preferences yet."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        UIAlertAction* setAction = [UIAlertAction actionWithTitle:@"Set preferences" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  int ind = 1;
                                                                  self.tabBarController.selectedIndex = ind;
                                                                  [self.tabBarController.viewControllers[ind] popToRootViewControllerAnimated:NO];
                                                              }];

        [alert addAction:defaultAction];
        [alert addAction:setAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (selected == 0){
        PFUser *user = [PFUser currentUser];
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:[[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue] longitude:[[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue]];
        [query whereKey:@"Geopoint" nearGeoPoint:currentPoint withinKilometers:[[[NSUserDefaults standardUserDefaults]valueForKey:@"radiusMax"]doubleValue]];
    } else if (selected == 1){
        NSArray *array = [[NSArray alloc]initWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"Category1"],[[NSUserDefaults standardUserDefaults]valueForKey:@"Category2"],[[NSUserDefaults standardUserDefaults]valueForKey:@"Category3"], nil];
        [query whereKey:@"Category" containedIn:array];
    } else {
        [query whereKey:@"Name" equalTo:self.searchBar.text];
    }
    
    [query orderByDescending:@"timeInterval"];
    [query setLimit:15];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
            if (events.count == 0) {
                for (UIView *view in self.tableView.subviews) {
                    [view setHidden:YES];
                    [view setUserInteractionEnabled:NO];
                }
                
                UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WelcomeMountain"]];
                logo.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.5);
                [self.tableView addSubview:logo];
                logo.tag = -4;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
                label.center = CGPointMake(self.view.frame.size.width/2, logo.frame.size.height+logo.frame.origin.y+30);
                [self.tableView addSubview:label];
                
                label.text = @"No events available. Be the first to create an event!";
                label.font = [UIFont fontWithName:@"Helvetica" size:18];
                
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 2;
                label.tag = -4;
                
            }
            else{
                for (UIView *view in self.tableView.subviews) {
                    [view setHidden:NO];
                    [view setUserInteractionEnabled:YES];
                    if (view.tag == -4) {
                        [view removeFromSuperview];
                    }
                }
                
            }
            //[self prepareImages];
            [self loadUsersInvitedOrRequesting];
        }
    }];
}

-(void)loadEventsWithCategory:(myButton*)sender{
    [events removeAllObjects];
    oneFinished = NO;
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    //[query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    [query whereKey:@"Category" equalTo:sender.userId];
    [query orderByDescending:@"timeInterval"];
    [query setLimit:15];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
            if (events.count == 0) {
                for (UIView *view in self.tableView.subviews) {
                    [view setHidden:YES];
                    [view setUserInteractionEnabled:NO];
                }
                
                UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WelcomeMountain"]];
                logo.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.5);
                [self.tableView addSubview:logo];
                logo.tag = -4;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
                label.center = CGPointMake(self.view.frame.size.width/2, logo.frame.size.height+logo.frame.origin.y+30);
                [self.tableView addSubview:label];
                
                label.text = @"No events available. Be the first to create an event!";
                label.font = [UIFont fontWithName:@"Helvetica" size:18];
                
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 2;
                label.tag = -4;
                
            }
            else{
                for (UIView *view in self.tableView.subviews) {
                    [view setHidden:NO];
                    [view setUserInteractionEnabled:YES];
                    if (view.tag == -4) {
                        [view removeFromSuperview];
                    }
                }
                
            }
            //[self prepareImages];
            [self loadUsersInvitedOrRequesting];
        }
    }];
}

-(void)loadEventsWithHouses{
    [events removeAllObjects];
    for (NSString *house in myHouses){
        oneFinished = NO;
        PFQuery *query = [PFQuery queryWithClassName:@"Events"];
        //[query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
        [query whereKey:@"Houses" equalTo:house];
        [query orderByDescending:@"timeInterval"];
        [query setLimit:15];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (!error){
                [events addObjectsFromArray:objects];
              //  [self prepareImages];
                [self loadUsersInvitedOrRequesting];
            }
        }];
    }
}

-(void)loadEventsWithFriends{
    [events removeAllObjects];
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbfriends"];
    for (NSString *friend in friends){
        oneFinished = NO;
        PFQuery *query = [PFQuery queryWithClassName:@"Events"];
        //[query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
        [query whereKey:@"Identities" equalTo:friend];
        [query orderByDescending:@"timeInterval"];
        [query setLimit:15];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (!error){
                [events addObjectsFromArray:objects];
               // [self prepareImages];
                [self loadUsersInvitedOrRequesting];
            }
        }];
    }
}


-(void)loadMyHouses{
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    if ([PFUser currentUser].objectId == nil) LoginUser(self);
    else {
        [query whereKey:@"Members" equalTo:[PFUser currentUser].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (error){
                NSLog(@"error");
            } else {
                myHouses = [[NSMutableArray alloc] init];
                for (PFObject *object in objects){
                    [myHouses addObject:object.objectId];
                }
            }
        }];
    }
}

-(void)loadUsers{
    [usersPerEvent removeAllObjects];
    for (PFObject *event in events){
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" containedIn:event[@"Identities"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [usersPerEvent addObject:objects];
                 if ([events indexOfObject:event] == events.count - 1){
                     [self loadHouses];
                 }
             }
             else [ProgressHUD showError:@"Network error."];
         }];
    }
    
}

-(void)loadUsersInvitedOrRequesting{
    [usersInvitedOrRequesting removeAllObjects];
    for (PFObject *event in events){
        NSMutableArray *array = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
        [array addObjectsFromArray:event[@"Invites"]];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" containedIn:array];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [usersInvitedOrRequesting addObject:objects];
                 if ([events indexOfObject:event] == events.count - 1){
                     [self loadUsers];
                 }
             }
             else [ProgressHUD showError:@"Network error."];
         }];
    }
}

-(void)loadHouses{
    [houses removeAllObjects];
    // Step 1: getting an array with unique elements corresponding to houses objectId
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:[[events objectAtIndex:0] objectForKey:@"Houses"]];
    for (int i = 0;i<events.count;i++){
        NSArray *array2 = [[NSArray alloc]initWithArray:[[events objectAtIndex:i] objectForKey:@"Houses"]];
        for (int j=0;j<array2.count;j++){
            if ([array containsObject:[array2 objectAtIndex:j]] == 0){
                [array addObject:[array2 objectAtIndex:j]];
            }
        }
    }
    // Step 2: making the query
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil){
            [houses addObjectsFromArray:objects];
            [self findCommonFriends];
        } else{
            [ProgressHUD showError:@"Network error."];
        }
    }];
}

-(void)findCommonFriends{
    [connectionsPerEvent removeAllObjects];
    NSMutableArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbfriends"];
    for (PFObject *group in events){
        NSMutableArray *presentFriends = [[NSMutableArray alloc]init];
        for (NSString *identity in friends){
            if ( [[group objectForKey:@"Identities"] containsObject:identity]){
                [presentFriends addObject:identity];
            }
        }
        [connectionsPerEvent addObject:presentFriends];
    }
    oneFinished = YES;
    self.tableView.tableHeaderView = nil;
    [self.tableView reloadData];
}

#pragma mark search bar

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self loadEvents:4];
}



-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    numero = selectedScope;
    if (selectedScope == 3){
        [self loadEventsWithFriends];
    } else if (selectedScope == 2){
        [self loadEventsWithHouses];
    } else [self loadEvents:selectedScope];
}


#pragma mark table view delegate and datasource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableHeader"];
    header.event = [events objectAtIndex:section];
    NSString *category = [header.event objectForKey:@"Category"];
    [header.buttonCategory addTarget:self action:@selector(loadEventsWithCategory:) forControlEvents:UIControlEventTouchUpInside];
    header.buttonCategory.userId = category;
    [header.buttonCategory setImage:[UIImage imageNamed:category] forState:UIControlStateNormal];
    header.nameButton.tag = section;
    [header.nameButton addTarget:self action:@selector(actionGroupSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    [header drawHeader];
    [header.adressButton addTarget:self action:@selector(actionItinerary:) forControlEvents:UIControlEventTouchUpInside];
    if ([[[events objectAtIndex:section] objectForKey:@"Location"] objectForKey:@"lat"] != nil){
    header.adressButton.coordinates1 = @{@"lat":[[[events objectAtIndex:section] objectForKey:@"Location"] objectForKey:@"lat"], @"long":[[[events objectAtIndex:section] objectForKey:@"Location"] objectForKey:@"long"]};
    }
    header.adressButton.userId = [[events objectAtIndex:section] objectForKey:@"Name"];
    return header;
}

-(void)actionItinerary:(myButton*)sender{
    double latitude = [[sender.coordinates1 objectForKey:@"lat"] doubleValue];
    double longitude = [[sender.coordinates1 objectForKey:@"long"] doubleValue];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:sender.userId];
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 63;
}

-(void)actionGroupSettings:(UIButton*)sender{
    GroupSettingsView *gsv = [[GroupSettingsView alloc]initWith:[events objectAtIndex:sender.tag]];
    gsv.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gsv animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return events.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)showGroup:(UITapGestureRecognizer*)sender{
    GroupSettingsView *gsv = [[GroupSettingsView alloc]initWith:[events objectAtIndex:sender.view.tag]];
    gsv.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gsv animated:YES];
}

-(void)actionRequestFromButton:(UIButton*)sender{

    PFObject *event = [events objectAtIndex:sender.tag];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    BOOL canJoinDirectly = NO;
    NSArray *channels = [[NSArray alloc] initWithArray:currentInstallation.channels];
    NSArray *househandle = [[NSArray alloc] initWithArray: event[@"Houses"]];
    NSString *houseId;
    for (int i = 0;i<househandle.count;i++){
        houseId = [@"h" stringByAppendingString:househandle[i]];
        if ([channels containsObject:houseId]) canJoinDirectly = YES;
    }
    if ([event[@"Invites"] containsObject:[PFUser currentUser].objectId]){
        canJoinDirectly = YES;
    }
    
    if ([event[@"Requests"] containsObject:[PFUser currentUser].objectId]){
        [self removeFromRequestList:sender];
    } else {
    if (![event[@"Identities"] containsObject:[PFUser currentUser].objectId]){
        if (!canJoinDirectly){
            [self putOnRequestList:sender];
        }else {
            [self putOnIdentitiesList:sender];
        }
    } else {
        if (canJoinDirectly){
            [self removeFromIdentitiesList:sender];
        } else {
            [self removeFromRequestList:sender];
        }
    }
    }
}

-(void)actionRequestFromDoubleTap:(UITapGestureRecognizer*)sender{
    justOnce = NO;
    
    UIImageView *likeView = [sender.view.subviews objectAtIndex:0];
    likeView.hidden = NO;
    likeView.alpha = 1.0;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{likeView.alpha = 0;} completion:^(BOOL finished) {
        if (finished) likeView.hidden = YES;
    }];
    
   BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.view.tag]];
    PFObject *event = [events objectAtIndex:cell.likeButton.tag];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    BOOL canJoinDirectly = NO;
    NSArray *channels = [[NSArray alloc] initWithArray:currentInstallation.channels];
    NSArray *househandle = [[NSArray alloc] initWithArray: event[@"Houses"]];
    NSString *houseId;
    for (int i = 0;i<househandle.count;i++){
        houseId = [@"h" stringByAppendingString:househandle[i]];
        if ([channels containsObject:houseId]) canJoinDirectly = YES;
    }
    if ([event[@"Invites"] containsObject:[PFUser currentUser].objectId]){
        canJoinDirectly = YES;
    }
    if (![event[@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
    if (canJoinDirectly){
        [self putOnIdentitiesList:cell.likeButton];
    } else {
        [self putOnRequestList:cell.likeButton];
    }
    }
   
}

-(void)putOnRequestList:(UIButton *)sender{
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    PFObject *event = [events objectAtIndex:cell.likeButton.tag];
    PFUser *user = [PFUser currentUser];
    [cell.likeButton setImage:[UIImage imageNamed:@"Requested"] forState:UIControlStateNormal];
    NSMutableArray *requests;
    if ([event[@"Requests"] count] != 0) {
        requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    } else {
        requests = [NSMutableArray new];
    }
    if (![requests containsObject:user.objectId]){
        [requests addObject:user.objectId];
    };
    NSArray *identityHandle =event[@"Identities"];
    cell.numberPeopleLabel.text = [NSString stringWithFormat:@"%lu interested", (unsigned long)identityHandle.count +requests.count ];
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         SendNotificationAboutRequestingToJoin(event, @"event");
         
     }];

    
[events replaceObjectAtIndex:cell.likeButton.tag withObject:event];
}

-(void)removeFromRequestList:(UIButton *)sender{
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    PFObject *event = [events objectAtIndex:cell.likeButton.tag];
    PFUser *user = [PFUser currentUser];
    
    [cell.likeButton setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
    NSMutableArray *requests;
    requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    [requests removeObject:user.objectId];
    NSArray *identityHandle =event[@"Identities"];
    cell.numberPeopleLabel.text = [NSString stringWithFormat:@"%lu interested", (unsigned long)identityHandle.count +requests.count ];
    [event saveInBackground];
[events replaceObjectAtIndex:cell.likeButton.tag withObject:event];
}

-(void)putOnIdentitiesList:(UIButton *)sender{
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    PFObject *event = [events objectAtIndex:cell.likeButton.tag];
    PFUser *user = [PFUser currentUser];
    NSArray *requestHandle = event[@"Requests"];
    NSMutableArray *identitiesHandle = [NSMutableArray arrayWithArray:event[@"Identities"]];
    if (![identitiesHandle containsObject:user.objectId]){
        [cell.likeButton setImage:[UIImage imageNamed:@"Going"] forState:UIControlStateNormal];
        [identitiesHandle addObject:user.objectId];
        cell.numberPeopleLabel.text = [NSString stringWithFormat:@"%lu interested", (unsigned long)identitiesHandle.count +requestHandle.count ];
        event[@"Identities"] = identitiesHandle;
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
                 NSLog(@"Network error");
             }
             NSDictionary *data = @{
                                    @"badge" : @"no",
                                    @"info" : @"GroupsView",
                                    @"alert": [NSString stringWithFormat:@"%@ is going to %@.",user[PF_USER_FULLNAME],event[@"Name"]]
                                    };
             PFPush *push = [[PFPush alloc] init];
             [push setChannel:[@"h" stringByAppendingString:event.objectId]];
             [push setData:data];
             [push sendPushInBackground];
             
         }];
    }

[events replaceObjectAtIndex:cell.likeButton.tag withObject:event];
}

-(void)removeFromIdentitiesList:(UIButton *)sender{
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
    PFObject *event = [events objectAtIndex:cell.likeButton.tag];
    PFUser *user = [PFUser currentUser];
    NSArray *requestHandle = event[@"Requests"];
    NSMutableArray *identitiesHandle = [NSMutableArray arrayWithArray:event[@"Identities"]];
    [identitiesHandle removeObject:user.objectId];
    
    cell.numberPeopleLabel.text = [NSString stringWithFormat:@"%lu interested", (unsigned long)identitiesHandle.count +requestHandle.count];
    event[@"Identities"] = identitiesHandle;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         SendNotificationAboutLeaving(event, @"event");
         
     }];
[events replaceObjectAtIndex:cell.likeButton.tag withObject:event];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = YES;
    cell.superview.userInteractionEnabled = YES;
    cell.superview.superview.userInteractionEnabled = YES;
    if (oneFinished){
        [refreshControl endRefreshing];
        cell.event = [events objectAtIndex:indexPath.section];
        
        cell.likeButton.tag = indexPath.section;
        if ([[cell.event objectForKey:@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
            cell.likeButton.userInteractionEnabled = NO;
        }
        [cell.likeButton addTarget:self action:@selector(actionRequestFromButton:) forControlEvents:UIControlEventTouchUpInside];
        
        PFUser *user = [PFUser currentUser];
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[[[[events objectAtIndex:indexPath.section] objectForKey:@"Location"] objectForKey:@"lat"] doubleValue] longitude:[[[[events objectAtIndex:indexPath.section] objectForKey:@"Location"] objectForKey:@"long"] doubleValue]];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[[[user objectForKey:@"geolocalisation"] objectForKey:@"lat"] doubleValue] longitude:[[[user objectForKey:@"geolocalisation"] objectForKey:@"long"] doubleValue]];
        CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    
        cell.distanceLabel.text = [NSString stringWithFormat:@"%i km",(int)distance/1000];
        [cell.requestButton setHidden:YES];
        if ([[cell.event objectForKey:@"Identities"] containsObject:user.objectId]){
            [cell.likeButton setImage:[UIImage imageNamed:@"Going"] forState:UIControlStateNormal];
        } else if ([[cell.event objectForKey:@"Requests"] containsObject:user.objectId]){
            [cell.likeButton setImage:[UIImage imageNamed:@"Requested"] forState:UIControlStateNormal];
        } else {
            [cell.likeButton setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
        }
        
        NSArray *array = [usersPerEvent objectAtIndex:indexPath.section];
        [cell.nameButton setTitle:[[array objectAtIndex:0]objectForKey:@"fullname_lower"] forState:UIControlStateNormal];
        if ([[events objectAtIndex:indexPath.section] objectForKey:@"Creator"]){
            cell.nameButton.userId = [[events objectAtIndex:indexPath.section] objectForKey:@"Creator"];
        } else {
            cell.nameButton.userId = [[[events objectAtIndex:indexPath.section] objectForKey:@"Creator"] objectAtIndex:0];
        }
        [cell.nameButton addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
        NSArray *requestArray = [[events objectAtIndex:indexPath.section]objectForKey:@"Requests"];
        cell.numberPeopleLabel.text = [NSString stringWithFormat:@"%lu interested",(unsigned long)array.count +requestArray.count];
        
        NSArray *array6 = [[events objectAtIndex:indexPath.section]objectForKey:@"Houses"];
        int i = 0;
        while ((i < 3) && (i<array.count)){
            myButton *button;
            button = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width -45, (i+1)*42 -30, 40,40)];
            
            PFFile *file = [[array objectAtIndex:i] objectForKey:@"thumbnail"];
            
            NSString *urlString = file.url;
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:5.0];
            [[NSOperationQueue mainQueue] cancelAllOperations];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                button.layer.cornerRadius = button.frame.size.width/2;
                button.layer.masksToBounds = YES;
                button.userId = [[array objectAtIndex:i]objectId];
                [button addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
                [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal] ;
                [cell addSubview:button];
            }];
            i = i+1;
        }
        if (array.count >= 3){
            myButton *button;
            button = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width -45, (i+1)*42 -30, 60,30)];
            NSString *stringforbutton = [NSString stringWithFormat:@"+%i",(int)array.count];
            [button setTitle:stringforbutton forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button sizeToFit];
            [button addTarget:self action:@selector(showGroup:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            
        }
        
        
        UIColor *color = [UIColor whiteColor];
        
        NSDictionary *attrs = @{ NSForegroundColorAttributeName : color , NSFontAttributeName : cell.nameButton.titleLabel.font};
        
        cell.descriptionTextView.text = @"";
        
        cell.descriptionTextView.text = [cell.descriptionTextView.text stringByAppendingString:[cell.nameButton titleForState:UIControlStateNormal]];
        cell.descriptionTextView.text = [cell.descriptionTextView.text stringByAppendingString:@": "];
        cell.descriptionTextView.text = [cell.descriptionTextView.text stringByAppendingString:[[events objectAtIndex:indexPath.section] objectForKey:@"Description"]];
        
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:cell.descriptionTextView.text];
        [attrStr addAttributes:attrs range:NSMakeRange(0, [cell.nameButton titleForState:UIControlStateNormal].length)];
        cell.descriptionTextView.text = @"";
        cell.descriptionTextView.attributedText = attrStr;
        
        NSMutableArray *array7 = [[NSMutableArray alloc]init];
        for (int i = 0; i<houses.count;i++){
            for (int j = 0; j<array6.count;j++){
                if ([[array6 objectAtIndex:j]isEqualToString:[[houses objectAtIndex:i] objectId]]){
                    [array7 addObject:[houses objectAtIndex:i]];
                }
            }
        }
        int j = 0;
        while ((j < array7.count) && (j<2)){
            myButton *button = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width -45, -(j+1)*42 + 265, 40,40)];
            PFFile *file = [[array7 objectAtIndex:j] objectForKey:@"Thumbnail"];
            NSString *urlString = file.url;
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:5.0];
            [[NSOperationQueue mainQueue] cancelAllOperations];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData *data, NSError *connectionError) {
                button.layer.cornerRadius = button.frame.size.width/2;
                button.layer.masksToBounds = YES;
                button.house = [array7 objectAtIndex:j];
                [button addTarget:self action:@selector(actionHouse:) forControlEvents:UIControlEventTouchUpInside];
                [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal] ;
                [cell addSubview:button];
            }];
            j = j+1;
        }
    
        cell.mainView.image = nil;
        [cell.mainView setBackgroundColor:[UIColor lightGrayColor]];
        PFFile *file = [[events objectAtIndex:indexPath.section] objectForKey:@"Picture"];
        NSString *urlString = file.url;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:5.0];
        [[NSOperationQueue mainQueue] cancelAllOperations];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData *data, NSError *connectionError) {
            cell.mainView.image = [UIImage imageWithData:data];
            [cell.mainView addSubview:cell.likeView];
            UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionRequestFromDoubleTap:)];
            doubletap.numberOfTapsRequired = 2;
            [cell.mainView addGestureRecognizer:doubletap];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnce:)];
            singleTap.numberOfTapsRequired = 1;
            [cell.mainView addGestureRecognizer:singleTap];
            
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGroup:)];
            swipe.direction = UISwipeGestureRecognizerDirectionLeft;
            [cell.mainView addGestureRecognizer:swipe];
            cell.mainView.tag = indexPath.section;
            cell.mainView.userInteractionEnabled = YES;
        }];

    }
    return cell;
}


-(void)tapOnce:(UITapGestureRecognizer*)sender{
    
    if (!sender.enabled) {
        return;
    }
    justOnce = YES;
    sender.enabled = NO;
    [self performSelector:@selector(moveAfterDelay:) withObject:sender afterDelay:.5];
    
}

-(void)moveAfterDelay:(UITapGestureRecognizer*)sender{
    sender.enabled = YES;
    
    if (justOnce) {
        justOnce = NO;
        GroupSettingsView *gsv = [[GroupSettingsView alloc]initWith:[events objectAtIndex:sender.view.tag]];
        gsv.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gsv animated:YES];
    }
}


-(void)actionHouse:(myButton *)sender{
    GroupsView *houseView = [[GroupsView alloc]init];
    houseView.house = sender.house;
    [self.navigationController pushViewController:houseView animated:YES];
}

-(void)actionProfile:(myButton *)sender{
    ProfileView *profileView = [[ProfileView alloc] initWith:sender.userId];
    [self.navigationController pushViewController:profileView animated:YES];
}

-(void)actionRequest:(myButton *)sender{
    
    PFObject *event = [events objectAtIndex:sender.tag];
    
    
    [sender setTitle:@"" forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"Requested"] forState:UIControlStateNormal];
    
    sender.userId = @"cancel request";
    [sender removeTarget:self action:@selector(actionRequest:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(actionCancelRequest:) forControlEvents:UIControlEventTouchUpInside];
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    [cell.likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
    
    
    NSMutableArray *requests;
    if ([event[@"Requests"] count] != 0) {
        requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    } else {
        requests = [NSMutableArray new];
    }
    [requests addObject:[[PFUser currentUser] objectId]];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:requests];
    requests = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
    
    event[@"Requests"] = requests;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         SendNotificationAboutRequestingToJoin(event, @"event");
         
     }];
    
}


-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:NO];
    
    return NO;
}


-(void)actionCancelRequest:(myButton *)sender{
    PFObject *event = [events objectAtIndex:sender.tag];
    NSMutableArray *requests;
    if ([event[@"Requests"] count] != 0) {
        requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    } else {
        requests = [NSMutableArray new];
    }
    
    [sender setTitle:@"" forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
    
    sender.userId = @"join";
    [sender removeTarget:self action:@selector(actionCancelRequest:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(actionRequest:) forControlEvents:UIControlEventTouchUpInside];
    BrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];
    [cell.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:requests];
    requests = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
    [requests removeObject:[[PFUser currentUser] objectId]];
    NSLog(@"%@",requests);
    event[@"Requests"] = requests;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         
     }];
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 356;
}

@end
