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
@interface HousesController ()
{
    NSMutableArray *users;
    NSMutableArray *houses;
}



@end

@implementation HousesController
int sel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"House"]];
        self.tabBarItem.title = @"Houses";
        
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
    self.title = @"Houses";
    [self loadHouses];
    [self.tableView registerNib:[UINib nibWithNibName:@"HouseCell" bundle:nil] forCellReuseIdentifier:@"HouseCell"];
    users = [[NSMutableArray alloc]init];
    houses = [[NSMutableArray alloc]init];
    }

-(void)actionNext{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (PFObject *house in houses){
        [array addObject:house.objectId];
    }
    self.event[@"Houses"] = array;
    FriendsController *fc = [[FriendsController alloc]init];
    fc.event = self.event;
    [self.navigationController pushViewController:fc animated:YES];
}

-(void)loadHouses{
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    [query whereKey:@"Members" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error){
            NSLog(@"error");
        } else {
            self.houses = [[NSMutableArray alloc] initWithArray:objects];
            [self loadUsersInHouses];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

-(void)loadUsersInHouses{
    
    for (PFObject *house in self.houses){
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    NSArray *array = [NSArray arrayWithArray:[house objectForKey:@"Members"]];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil){
            [users addObject:objects];
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

    return 1;
}
-(void)createHouse {
    CreateHouseController *chc = [[CreateHouseController alloc]init];
    [self.navigationController pushViewController:chc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.houses.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
    return @"Affiliate your event with houses";
    } else return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   HouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseCell" forIndexPath:indexPath];
    
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
     [cell setR:[self.houses objectAtIndex:indexPath.row]];
       if ([houses containsObject:[self.houses objectAtIndex:indexPath.row]]){
         cell.selectedView.image = [UIImage imageNamed:@"Ok-32"];
       } else {
         cell.selectedView.image = [UIImage imageNamed:@"Full Moon Filled-32"];
       }
    } else {
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setR:[self.houses objectAtIndex:indexPath.row]];
    }
    return cell;
    }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ){
        if ([houses containsObject:[self.houses objectAtIndex:indexPath.row]]){
            [houses removeObject:[self.houses objectAtIndex:indexPath.row]];
        } else {
        [houses addObject:[self.houses objectAtIndex:indexPath.row]];
        }
        [self.tableView reloadData];
    }else{
    GroupsView *detailViewController = [[GroupsView alloc] init];
    detailViewController.users = [users objectAtIndex:indexPath.row];
    detailViewController.house =[self.houses objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
