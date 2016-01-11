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

@import GoogleMaps;

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
    
    NSMutableArray *myHouses;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

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
    [GMSServices provideAPIKey:@"AIzaSyCMdkKlurqOvobVq2GHf5iXmTi4eliXVac"];
    self.title = @"Browser";
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.showsScopeBar = YES;
    events = [[NSMutableArray alloc]init];
    usersInvitedOrRequesting = [[NSMutableArray alloc]init];
    connectionsPerEvent = [[NSMutableArray alloc]init];
    usersPerEvent = [[NSMutableArray alloc]init];
    houses = [[NSMutableArray alloc]init];
    [self loadEvents:0];
    [self loadMyHouses];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionSearch)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.searchBar.scopeButtonTitles = @[@"Around me",@"Preferences",@"My Houses", @"Friends"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BrowserCell" bundle:nil] forCellReuseIdentifier:@"BrowserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"TableHeader"];
    
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
    
    if (selected == 0){
        PFUser *user = [PFUser currentUser];
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:[[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue] longitude:[[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue]];
        [query whereKey:@"Geopoint" nearGeoPoint:currentPoint];
    } else if (selected == 1){
        NSArray *array = [[NSArray alloc]initWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"Category1"],[[NSUserDefaults standardUserDefaults]valueForKey:@"Category2"],[[NSUserDefaults standardUserDefaults]valueForKey:@"Category3"], nil];
        [query whereKey:@"Category" containedIn:array];
    } else {
        [query whereKey:@"Name" equalTo:self.searchBar.text];
    }
    
    [query orderByDescending:@"timeInterval"];
    [query setLimit:5];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
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
        [query setLimit:5];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (!error){
                [events addObjectsFromArray:objects];
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
        [query setLimit:3];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (!error){
                [events addObjectsFromArray:objects];
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
        [query setLimit:3];
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
            if (!error){
                [events addObjectsFromArray:objects];
                [self loadUsersInvitedOrRequesting];
            }
        }];
    }
}


-(void)loadMyHouses{
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
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
                 [self loadUsers];
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
    return header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (oneFinished){
        [refreshControl endRefreshing];
        cell.event = [events objectAtIndex:indexPath.section];
            if ([[events objectAtIndex:indexPath.section] objectForKey:@"Picture"] != nil){
            [cell.mainView setFile:[[events objectAtIndex:indexPath.section] objectForKey:@"Picture"]];
            [cell.mainView loadInBackground];
        } else {
            GMSPanoramaView *panoView = [[GMSPanoramaView alloc] initWithFrame:cell.mainView.frame];
            [panoView setAllGesturesEnabled:NO];
            CGFloat nearestLat = floorf([[cell.event[@"Location"] objectForKey:@"lat"] doubleValue] * 1000 + 0.5) / 1000;
            CGFloat nearestLong = floorf([[cell.event[@"Location"] objectForKey:@"long"] doubleValue] * 1000 + 0.5) / 1000;
            [panoView moveNearCoordinate:CLLocationCoordinate2DMake(nearestLat,nearestLong)];
            [cell addSubview:panoView];
        }
        PFUser *user = [PFUser currentUser];
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[[[[events objectAtIndex:indexPath.section] objectForKey:@"Location"] objectForKey:@"lat"] doubleValue] longitude:[[[[events objectAtIndex:indexPath.section] objectForKey:@"Location"] objectForKey:@"lat"] doubleValue]];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[[[user objectForKey:@"Geolocalisation"] objectForKey:@"lat"] doubleValue] longitude:[[[user objectForKey:@"Geolocalisation"] objectForKey:@"long"] doubleValue]];
        CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%i km away",(int)distance/1000];
        
        [cell.requestButton setTag:indexPath.row];
        if ([[cell.event objectForKey:@"Identities"] containsObject:user.objectId]){
            [cell.requestButton setTitle:@"Going" forState:UIControlStateNormal];
            [cell.requestButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1]forState:UIControlStateNormal];
            cell.requestButton.enabled = NO;
        } else if ([[cell.event objectForKey:@"Requests"] containsObject:user.objectId]){
            [cell.requestButton setTitle:@"Cancel Request" forState:UIControlStateNormal];
            [cell.requestButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [cell.requestButton addTarget:self action:@selector(actionCancelRequest:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.requestButton setTitle:@"Request" forState:UIControlStateNormal];
            [cell.requestButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [cell.requestButton addTarget:self action:@selector(actionRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSArray *array = [usersPerEvent objectAtIndex:indexPath.section];
        NSArray *array2 = [connectionsPerEvent objectAtIndex:indexPath.section];
        cell.peopleLabel.text = [NSString stringWithFormat:@"%lu going, %lu that you know.",(unsigned long)array.count,(unsigned long)array2.count];
        
        NSArray *array3 = [[events objectAtIndex:indexPath.section]objectForKey:@"Invites"];
        NSArray *array4 = [[events objectAtIndex:indexPath.section]objectForKey:@"Requests"];
        cell.inviteLabel.text = [NSString stringWithFormat:@"%lu invites, %lu requests.",(unsigned long)array3.count,(unsigned long)array4.count];
        
        NSMutableArray *array5 = [[NSMutableArray alloc]init];
        for (int i = 0; i<array.count;i++){
            for (int j = 0; j<array2.count;j++){
                if ([[array2 objectAtIndex:j]isEqualToString:[[array objectAtIndex:i] objectForKey:@"objectId"]]){
                    [array5 addObject:[array objectAtIndex:i]];
                }
            }
        }
        NSArray *array6 = [[events objectAtIndex:indexPath.section]objectForKey:@"Houses"];
        if (array.count > 4) {
            cell.morePeopleLabel.text = [NSString stringWithFormat:@"+%lu",array.count - 4 ];
        } else cell.morePeopleLabel.text = nil;
        if (array6.count > 4){
            cell.moreHousesLabel.text = [NSString stringWithFormat:@"+%lu",array6.count - 4 ];
        }else [cell.moreHousesLabel setHidden:YES];
        
        
        NSArray *arrayInvites = [usersInvitedOrRequesting objectAtIndex:indexPath.section];
        int k = 0;
        while (k < arrayInvites.count){
            myButton *button;
            if (arrayInvites.count >= 4){
                button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 57 -k*20, cell.frame.size.height - 53, 25, 25)];
            } else {
                button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 30 -k*20, cell.frame.size.height - 53, 25, 25)];
            }
            PFFile *file = [[arrayInvites objectAtIndex:k] objectForKey:@"thumbnail"];
            [button setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]]] forState:UIControlStateNormal];
            button.layer.cornerRadius = button.frame.size.width/2;
            button.layer.masksToBounds = YES;
            button.userId = [[arrayInvites objectAtIndex:k]objectId];
            [button addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            k = k+1;
        }
        
        
        int i = 0;
        while (i < array5.count){
            myButton *button;
            if (array5.count >= 4){
                button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 57 -i*20, cell.frame.size.height - 79, 25, 25)];
            } else {
                button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 30 -i*20, cell.frame.size.height - 79, 25, 25)];
            }
            PFFile *file = [[array5 objectAtIndex:i] objectForKey:@"thumbnail"];
            [button setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]]] forState:UIControlStateNormal];
            button.layer.cornerRadius = button.frame.size.width/2;
            button.layer.masksToBounds = YES;
            button.userId = [[array5 objectAtIndex:i]objectId];
            [button addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            i = i+1;
        }
        while ((i < 3) && (i < array.count)){
            myButton *button;
            if (array.count >= 4){
            button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 57 -i*20, cell.frame.size.height - 79, 25, 25)];
            } else {
            button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 30 -i*20, cell.frame.size.height - 79, 25, 25)];
            }
            PFFile *file = [[array objectAtIndex:i] objectForKey:@"thumbnail"];
            [button setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]]] forState:UIControlStateNormal];
            button.layer.cornerRadius = button.frame.size.width/2;
            button.layer.masksToBounds = YES;
            button.userId = [[array objectAtIndex:i]objectId];
            [button addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            i = i+1;
        }
        
        
        [cell.nameButton setTitle:[[array objectAtIndex:0]objectForKey:@"fullname_lower"] forState:UIControlStateNormal];
        if (cell.event[@"Creator"]){
        cell.nameButton.userId = cell.event[@"Creator"];
        } else {
           cell.nameButton.userId = [cell.event[@"Identities"] objectAtIndex:0];
        }
        [cell.nameButton addTarget:self action:@selector(actionProfile:) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:13]};
        CGSize stringsize = [cell.nameButton.titleLabel.text sizeWithAttributes:attributes];
        [cell.nameButton setFrame:CGRectMake(5,310,stringsize.width, 21)];
        cell.descriptionTextView.text = @"   ";
        CGSize stringsize2 = [cell.descriptionTextView.text sizeWithAttributes:attributes];
        while (stringsize.width >= stringsize2.width - 10){
            cell.descriptionTextView.text = [cell.descriptionTextView.text stringByAppendingString:@" "];
            stringsize2 = [cell.descriptionTextView.text sizeWithAttributes:attributes];
        }
        cell.descriptionTextView.text = [cell.descriptionTextView.text stringByAppendingString:[[events objectAtIndex:indexPath.section]objectForKey:@"Description"]];
        
        
        
        NSMutableArray *array7 = [[NSMutableArray alloc]init];
        for (int i = 0; i<houses.count;i++){
            for (int j = 0; j<array6.count;j++){
                if ([[array6 objectAtIndex:j]isEqualToString:[[houses objectAtIndex:i] objectId]]){
                    [array7 addObject:[houses objectAtIndex:i]];
                }
            }
        }
        int j = 0;
        while (j < array7.count){
            myButton *button = [[myButton alloc]initWithFrame:CGRectMake(cell.frame.size.width - 30 -j*20, cell.frame.size.height - 26, 25, 25)];
            PFFile *file = [[array7 objectAtIndex:j] objectForKey:@"Thumbnail"];
            [button setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]]] forState:UIControlStateNormal];
            button.layer.cornerRadius = button.frame.size.width/2;
            button.layer.masksToBounds = YES;
            button.house = [array7 objectAtIndex:j];
            [button addTarget:self action:@selector(actionHouse:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            j = j+1;
        }
        NSString *plural;
        if (array7.count != 1) plural = @"s";
        else plural = @"";
        cell.houseLabel.text = [NSString stringWithFormat:@"%lu house%@ sponsoring.",(unsigned long)array7.count,plural ];
    }
    return cell;
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
    NSMutableArray *requests;
    if ([event[@"Requests"] count] != 0) {
        requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    } else {
        requests = [NSMutableArray new];
    }
    [requests addObject:[[PFUser currentUser] objectId]];
    event[@"Requests"] = requests;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
     }];
}

-(void)actionCancelRequest:(myButton *)sender{
    PFObject *event = [events objectAtIndex:sender.tag];
    NSMutableArray *requests;
    if ([event[@"Requests"] count] != 0) {
        requests = [NSMutableArray arrayWithArray:event[@"Requests"]];
    } else {
        requests = [NSMutableArray new];
    }
    [requests removeObject:[[PFUser currentUser] objectId]];
    event[@"Requests"] = requests;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil){
             [ProgressHUD showError:@"Network error."];
             NSLog(@"Network error");
         }
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
     }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 435;
}

@end
