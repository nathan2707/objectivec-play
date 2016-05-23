//
//  RecentView.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "common.h"
#import "recent.h"
#import "CategoryChoiceController.h"
#import "RecentView.h"
#import "RecentCell.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"
#import "NavigationController.h"
#import "GroupSettingsView.h"
#import "push.h"

@interface RecentView()
{
	NSMutableArray *recents;
    NSMutableArray *events;
    BOOL finished;
}
@end

@implementation RecentView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"Events"]];
		self.tabBarItem.title = @"Events";
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"Events";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
																						   action:@selector(actionCompose)];
	[self.tableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:nil] forCellReuseIdentifier:@"RecentCell"];
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadEvents) forControlEvents:UIControlEventValueChanged];
	recents = [[NSMutableArray alloc] init];
    events = [[NSMutableArray alloc] init];
    [self loadEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([PFUser currentUser] != nil)
	{
		[self loadEvents];
	}
	else LoginUser(self);
}

#pragma mark - Backend methods

- (void)loadRecents
{
    finished = NO;
	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
	[query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
	[query includeKey:PF_RECENT_LASTUSER];
	[query orderByDescending:PF_RECENT_UPDATEDACTION];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[recents removeAllObjects];
			[recents addObjectsFromArray:objects];
            
			[self.tableView reloadData];
			[self updateTabCounter];
            [self loadEvents];
		}
		else [ProgressHUD showError:@"Network error."];
		[self.refreshControl endRefreshing];
	}];
}

-(void)loadEvents{
    finished = NO;
//    NSMutableArray *ids = [[NSMutableArray alloc] init];
//    for (int i =0;i<recents.count;i++){
//        [ids addObject:[[recents objectAtIndex:i] objectForKey:PF_RECENT_GROUPID]];
//    }
    PFQuery *query8 = [PFQuery queryWithClassName:@"Events"];
    [query8 whereKey:@"Identities" equalTo:[PFUser currentUser].objectId];
    [query8 orderByDescending:@"timeInterval"];
    [query8 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [events removeAllObjects];
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
                 
                 label.text = @"No events available. Create an event or explore!";
                 label.font = [UIFont fontWithName:@"Helvetica" size:18];
                 
                 label.textAlignment = NSTextAlignmentCenter;
                 label.numberOfLines = 2;
                 label.tag = -4;
                 
             }
             else{
            
                 [recents removeAllObjects];
                 for (PFObject *event in events){
                     [recents addObject:event[@"Recent"]];
                 }

                 for (UIView *view in self.tableView.subviews) {
                     [view setHidden:NO];
                     [view setUserInteractionEnabled:YES];
                     if (view.tag == -4) {
                         [view removeFromSuperview];
                     }
                 }
                 
             }
             finished = YES;
             [self.tableView reloadData];
             [self updateTabCounter];
             
         }
         else [ProgressHUD showError:@"Network error."];
         [self.refreshControl endRefreshing];
     }];

}

#pragma mark - Helper methods


- (void)updateTabCounter

{
	int total = 0;
	for (PFObject *recent in recents)
	{
		total += [recent[PF_RECENT_COUNTER] intValue];
	}
	UITabBarItem *item = self.tabBarController.tabBar.items[4];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

- (void)actionChat:(NSString *)groupId
{
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

- (void)actionCleanup
{
	[recents removeAllObjects];
	[self.tableView reloadData];
	[self updateTabCounter];
}

- (void)actionCompose
{
    int index = 2;
    self.tabBarController.selectedIndex = index;
    [self.tabBarController.viewControllers[index] popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [recents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
    if (finished){
        if (events.count > indexPath.row){
            PFObject *event = [events objectAtIndex:indexPath.row];
            cell.address = [event[@"Location"] objectForKey:@"adress"];
            cell.date = event[@"Date"];
            NSArray *array = [[NSArray alloc]initWithArray:event[@"Identities"]];
            cell.labelPeople.text = [NSString stringWithFormat:@"%lu people going",(unsigned long)array.count];
            [cell bindData:[recents objectAtIndex:indexPath.row]];
            cell.imageUser.layer.cornerRadius = cell.imageUser.frame.size.width/2;
            cell.imageUser.layer.masksToBounds = YES;
            [cell.imageUser setFile:event[@"Picture"]];
            [cell.imageUser loadInBackground];
//            for (PFObject *recent in recents) {
//                
//                //if ([recent[@"groupId"] isEqualToString:event.objectId]) {
//                    
//                    [cell bindData:recent];
//                    break;
//                //}
//            }
            
        }
        
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)sendNotif:(NSString *)message :(NSString*)groupid{
    NSDictionary *data = @{
                           @"badge" : @"Increment",
                           @"info" : @"GroupSettingsView",
                           @"alert": message
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:groupid];
    [push setData:data];
    [push sendPushInBackground];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
	PFObject *recent = recents[indexPath.row];

    PFObject *group = [events objectAtIndex:indexPath.row];
    if (([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) && ([group[@"Creator"] isEqualToString:[[PFUser currentUser] objectId]])){
        PFUser *user = [PFUser currentUser];
        NSString *channel = [@"h" stringByAppendingString:group[@"Name"]];
        [self sendNotif:[NSString stringWithFormat:@"%@ cancelled %@",user[PF_USER_FULLNAME],channel]:group.objectId];
        
        [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
             } else {
                 [self.tableView beginUpdates];
                 [recents removeObject:recent];
                 [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView endUpdates];
             }
         }];
        
    } else if (([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) && ([group[@"Creator"] isEqualToString:[[PFUser currentUser] objectId]] == NO)){
        
        NSMutableArray *identities = [[NSMutableArray alloc]initWithArray:group[@"Identities"]];
        [identities removeObject:[[PFUser currentUser]objectId]];
        group[@"Identities"] = identities;
        NSMutableArray *users = [[NSMutableArray alloc]initWithArray:recent[@"Members"]];
        [users removeObject:[PFUser currentUser]];
        group[@"Users"] = users;
        group[@"Recent"] = recent;
        [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
             } else {
                 SendNotificationAboutLeaving(group, @"event");
                 [self updateTabCounter];
                 [self.tableView beginUpdates];
                  [recents removeObject:recent];
                 [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView endUpdates];
             }
         }];

    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupSettingsView *groupSettingsView = [[GroupSettingsView alloc] initWith:[events objectAtIndex:indexPath.row ]];
    groupSettingsView.hidesBottomBarWhenPushed = YES;
    PFObject *recent = recents[indexPath.row];
    groupSettingsView.recent = recent;
    [self.navigationController pushViewController:groupSettingsView animated:YES];
    
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	PFObject *recent = recents[indexPath.row];
//	[self actionChat:recent[PF_RECENT_GROUPID]];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[events objectAtIndex:indexPath.row]objectForKey:@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
        return @"Cancel";
    }
    return @"Leave";
}

@end
