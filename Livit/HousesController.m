//
//  HousesController.m
//  Livit
//
//  Created by Nathan on 12/12/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "HousesController.h"
#import "HouseCell.h"
#import "FriendsController.h"
#import "GroupsView.h"
#import "CreateHouseController.h"
#import "AppConstant.h"
#import "myButton.h"
#import "AddressBookView.h"
@interface HousesController ()
{
    NSMutableArray *users;
    NSMutableArray *housesBIS;
    NSMutableArray *suggestions;
    NSMutableArray *suggestedUsers;
    NSMutableArray *eventsPerHouse;
}

@end

@implementation HousesController
int sel;
BOOL finished;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"House"]];
        self.tabBarItem.title = @"Circles";
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Next" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0,0,50,35);
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = barButton;
    
    } else {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createHouse)];
        [barButton setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = barButton;
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(loadHouses) forControlEvents:UIControlEventValueChanged];
    }
    self.title = @"Circles";
    [self.tableView registerNib:[UINib nibWithNibName:@"HouseCell" bundle:nil] forCellReuseIdentifier:@"HouseCell"];
    finished = NO;
    [self loadHouses];
    users = [[NSMutableArray alloc]init];
    housesBIS = [[NSMutableArray alloc]init];
    suggestions = [[NSMutableArray alloc]init];
    suggestedUsers = [[NSMutableArray alloc]init];
    eventsPerHouse = [[NSMutableArray alloc]init];
    }

-(void)actionNext{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableArray *arrayNames = [[NSMutableArray alloc]init];
    for (PFObject *house in housesBIS){
        [array addObject:house.objectId];
        [arrayNames addObject:house[@"Name"]];
    }
    self.event[@"Houses"] = array;
    self.event[@"HousesNames"] = arrayNames;
    
    PFUser *user = [PFUser currentUser];
    if (user[@"PicURL"] != nil){
    FriendsController *fc = [[FriendsController alloc]init];
    fc.event = self.event;
    [self.navigationController pushViewController:fc animated:YES];
    } else {
        AddressBookView *abv = [[AddressBookView alloc]init];
        abv.group = self.event;
        abv.needsToPushForth = YES;
        abv.needsToPushBack = NO;
        [self.navigationController pushViewController:abv animated:YES];
    }
}

-(void)loadHouses{
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    [query whereKey:@"Members" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error){
            NSLog(@"error");
        } else {
            self.houses = [[NSMutableArray alloc] initWithArray:objects];
            if (self.houses.count == 0) {
                UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WelcomeMountain"]];
                logo.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.5);
                [self.tableView addSubview:logo];
                logo.tag = -4;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
                label.center = CGPointMake(self.view.frame.size.width/2, logo.frame.size.height+logo.frame.origin.y+30);
                [self.tableView addSubview:label];
                
                label.text = @"No houses available. Create a house or join a friend's!";
                label.font = [UIFont fontWithName:@"Helvetica" size:18];
                
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 2;
                label.tag = -4;
                
                //[self suscribe];
                
            }
            else{
                for (UIView *view in self.tableView.subviews) {
                    if (view.tag == -4) {
                        [view removeFromSuperview];
                    }
                }
            }
            [self loadEvents];
            [self.refreshControl endRefreshing];
        }
    }];
}

//-(void)suscribe{
//    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
//    NSMutableArray *houseNames = [[NSMutableArray alloc]init];
//    for (PFObject *house in self.houses){
//        [houseNames addObject:house.objectId];
//    }
//    for (NSString *suscribedChannel in subscribedChannels){
//        if(![houseNames containsObject:suscribedChannel]){
//            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//            [currentInstallation addUniqueObject:suscribedChannel forKey:@"channels"];
//            [currentInstallation saveInBackground];
//        }
//    }
//}



-(void)loadSuggestions{
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    PFUser *user = [PFUser currentUser];
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:[[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue] longitude:[[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue]];
    [query whereKey:@"Geopoint" nearGeoPoint:currentPoint withinKilometers:[[[NSUserDefaults standardUserDefaults]valueForKey:@"radiusMax"]doubleValue]];
    [query whereKey:@"Members" notEqualTo:user.objectId];
    [query setLimit:5];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error){
            NSLog(@"error");
        } else {
            suggestions = [[NSMutableArray alloc] initWithArray:objects];
            [self loadUsersInHouses:YES];
            finished = YES;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

-(void)loadUsersInHouses:(BOOL)sug{
    if (sug){
        for (PFObject *house in suggestions){
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            NSArray *array = [NSArray arrayWithArray:[house objectForKey:@"Members"]];
            [query whereKey:@"objectId" containedIn:array];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil){
                    [suggestedUsers addObject:objects];
                        PFQuery *query = [PFQuery queryWithClassName:@"Events"];
                        [query whereKey:@"Houses" equalTo:house.objectId];
                        [query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
                        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
                            if (!error){
                                [eventsPerHouse addObject:objects];
                            }
                        }];
                    [self loadUsersInHouses:NO];
                }
            }];
        }
  
    } else {
    
    for (PFObject *house in self.houses){
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    NSArray *array = [NSArray arrayWithArray:[house objectForKey:@"Members"]];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil){
            [users addObject:objects];
            if ( self == [self.navigationController.viewControllers objectAtIndex:0] ){
                [self loadSuggestions];
            } else {
                if (house == [self.houses lastObject]){
                finished = YES;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                }
            }
        }
    }];
}
    }
}

-(void)loadEvents{
    for (PFObject *house in self.houses){
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Houses" equalTo:house.objectId];
    [query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [eventsPerHouse addObject:objects];
            if (house == [self.houses lastObject])[self loadUsersInHouses:NO];
        }
    }];
    }
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 76;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
    return 1;
    }
    else return 2;
}
-(void)createHouse {
    CreateHouseController *chc = [[CreateHouseController alloc]init];
    [self.navigationController pushViewController:chc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.houses.count;
    else return suggestions.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
    return @"Circles";
    } else {
        if (section == 0) return @"Currently part of";
        if (section == 1) return @"Suggested";
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   HouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseCell" forIndexPath:indexPath];
    if (finished){
    NSArray *array = [eventsPerHouse objectAtIndex:indexPath.row];
    cell.numberEvents.text = [NSString stringWithFormat:@"%lu %@ this week",(unsigned long)array.count, (array.count > 1) ? @"events" : @"event" ];
    if (indexPath.section == 0){
    
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
     [cell setR:[self.houses objectAtIndex:indexPath.row]];
       if ([housesBIS containsObject:[self.houses objectAtIndex:indexPath.row]]){
         cell.selectedView.image = [UIImage imageNamed:@"OK-32"];
       } else {
         cell.selectedView.image = [UIImage imageNamed:@"Full Moon Filled-32"];
       }
    } else {
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setR:[self.houses objectAtIndex:indexPath.row]];
    }
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setR:[suggestions objectAtIndex:indexPath.row]];
        
        myButton *joinButton = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-85, 27, 75, 20)];
        [joinButton addTarget:self action:@selector(actionJoin:) forControlEvents:UIControlEventTouchUpInside];
        joinButton.tag = indexPath.row;
        joinButton.titleLabel.font = [UIFont systemFontOfSize: 13];
        
        if ([[[suggestions objectAtIndex:indexPath.row ] objectForKey:@"Requests"] containsObject:[PFUser currentUser].objectId]) {
            [joinButton setTitle:@"Requested" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [joinButton setBackgroundColor:[UIColor lightGrayColor]];
            joinButton.layer.cornerRadius = 3;
            [[joinButton layer] setBorderWidth:0.5f];
            [[joinButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            joinButton.userId = @"cancel request";
        } else {
            [joinButton setTitle:@"Join" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
            [joinButton setBackgroundColor:[UIColor whiteColor]];
            joinButton.layer.cornerRadius = 3;
            [[joinButton layer] setBorderWidth:0.5f];
            [[joinButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
            joinButton.userId = @"join";
        }
        
        [cell addSubview:joinButton];
        
    }
    }
    return cell;
    }

-(void)actionJoin:(myButton*)sender{
    PFObject *house = [suggestions objectAtIndex:sender.tag];
        if ([sender.userId isEqualToString:@"cancel request"]){
        
        [sender setTitle:@"Join" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor whiteColor]];
        sender.layer.cornerRadius = 3;
        [[sender layer] setBorderWidth:0.5f];
        [[sender layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        sender.userId = @"join";
        
        NSMutableArray *handle;
        if (house[@"Requests"] != nil) handle = [[NSMutableArray alloc]initWithArray:house[@"Requests"]];
        else handle = [[NSMutableArray alloc]init];
        [handle removeObject:[PFUser currentUser].objectId];
        house[@"Requests"] = handle;
        [house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                NSLog(@"error");
            }
        }];
        
    } else {
            [sender setTitle:@"Requested" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [sender setBackgroundColor:[UIColor lightGrayColor]];
            sender.layer.cornerRadius = 3;
            [[sender layer] setBorderWidth:0.5f];
            [[sender layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            sender.userId = @"cancel request";
            
        NSMutableArray *handle;
        if (house[@"Requests"] != nil) handle = [[NSMutableArray alloc]initWithArray:house[@"Requests"]];
        else handle = [[NSMutableArray alloc]init];
            [handle addObject:[PFUser currentUser].objectId];
            house[@"Requests"] = handle;
            [house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error){
                    NSLog(@"error");
                }
            }];
        }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
        if ([housesBIS containsObject:[self.houses objectAtIndex:indexPath.row]]){
            [housesBIS removeObject:[self.houses objectAtIndex:indexPath.row]];
        } else {
        [housesBIS addObject:[self.houses objectAtIndex:indexPath.row]];
        }
        [self.tableView reloadData];
        
    }else{
        
    GroupsView *detailViewController = [[GroupsView alloc] init];
    
    if (indexPath.section == 0){
    detailViewController.users = [users objectAtIndex:indexPath.row];
    detailViewController.house =[self.houses objectAtIndex:indexPath.row];
    } else {
    detailViewController.users = [suggestedUsers objectAtIndex:indexPath.row];
    detailViewController.house =[suggestions objectAtIndex:indexPath.row];
    }
    detailViewController.events = [eventsPerHouse objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0)return YES;
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //leave house
}

@end
