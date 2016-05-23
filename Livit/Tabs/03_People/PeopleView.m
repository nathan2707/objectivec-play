//
//  PeopleView.m
//  Livit
//
//  Created by Nathan on 10/14/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"
#import "ProfileView.h"
#import "AppConstant.h"
#import "common.h"
#import "people.h"
#import "recent.h"
#import "PeopleCell.h"
#import "PeopleView.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FriendsController.h"
#import "NavigationController.h"
#import "push.h"

@interface PeopleView()<FacebookFriendsDelegate>
{
	BOOL skipLoading;
    NSMutableArray *users;
	NSMutableArray *userIds;
	NSMutableArray *sections;
    PFUser *userSelected;
}
@end

@implementation PeopleView
@synthesize group;

- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"People";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
																						   action:@selector(actionAdd)];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeopleCell" bundle:nil] forCellReuseIdentifier:@"PeopleCell"];
	self.tableView.tableFooterView = [[UIView alloc] init];
	userIds = [[NSMutableArray alloc] init];
    users = [[NSMutableArray alloc] init];
    userSelected = [[PFUser alloc]init];
    if (group[@"Invites"]!=nil){
    for (PFUser *requester in self.requesters){
        requester[@"letter"] = @"R";
    }
    for (PFUser *inviter in self.invited){
        inviter[@"letter"] = @"I";
    }
    for (PFUser *member in self.usersCurrent){
        member[@"letter"] = @"M";
    }
    }
    [users addObjectsFromArray:self.requesters];
    [users addObjectsFromArray:self.invited];
    [users addObjectsFromArray:self.usersCurrent];
    for (PFUser *user in users){
        [userIds addObject:user.objectId];
    }
    [self setObjects:users];
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated

{
	[super viewDidAppear:animated];

	if ([PFUser currentUser] != nil)
	{
		if (skipLoading) skipLoading = NO;
	}
	else LoginUser(self);
}

#pragma mark - User actions


- (void)setObjects:(NSArray *)objects
{
	if (sections != nil) [sections removeAllObjects];
	NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
	sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	for (NSUInteger i=0; i<sectionTitlesCount; i++)
	{
		[sections addObject:[NSMutableArray array]];
	}
	NSArray *sorted = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		PFUser *user1 = (PFUser *)obj1;
		PFUser *user2 = (PFUser *)obj2;
		return [user1[PF_USER_FULLNAME] compare:user2[PF_USER_FULLNAME]];
	}];
		for (PFUser *object in sorted)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(fullname)];
		[sections[section] addObject:object];
	}
}

#pragma mark - User actions

- (void)actionCleanup
{
	[users removeAllObjects];
	[userIds removeAllObjects];
	[sections removeAllObjects];
	[self.tableView reloadData];
}

- (void)actionAdd

{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
								   otherButtonTitles: @"Address Book", @"Facebook Friends", nil];
    action.tag = 9;
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (actionSheet.tag == 7){
        if (buttonIndex != actionSheet.cancelButtonIndex){
            if (buttonIndex == 1)
            {
                ProfileView *profileView = [[ProfileView alloc] initWith:userSelected.objectId];
                [self.navigationController pushViewController:profileView animated:YES];
            }
            if (buttonIndex == 0)
            {
                PFUser *user1 = [PFUser currentUser];
                NSString *groupId = StartPrivateChat(user1, userSelected);
                ChatView *chatView = [[ChatView alloc] initWith:groupId];
                chatView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatView animated:YES];
            }
        }
        
    } else if (actionSheet.tag == 9){
    
    
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		skipLoading = YES;
		if (buttonIndex == 2)
		{
			SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
			selectSingleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 2)
		{
			SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
			selectMultipleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 0)
		{
			AddressBookView *addressBookView = [[AddressBookView alloc] init];
            addressBookView.delegate = self;
            addressBookView.group = self.group;
            addressBookView.needsToPushBack = NO;
            addressBookView.needsToPushForth = NO;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addressBookView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 1)
		{
			FriendsController *facebookFriendsView = [[FriendsController alloc] init];
			facebookFriendsView.delegate = self;
            [self.navigationController pushViewController:facebookFriendsView animated:YES];
        }
	}
    
    }
    
}

#pragma mark - SelectSingleDelegate

- (void)didSelectSingleUser:(PFUser *)user

{
	[self addUser:user];
}

#pragma mark - SelectMultipleDelegate

- (void)didSelectMultipleUsers:(NSMutableArray *)users_
{
	for (PFUser *user in users_)
	{
		[self addUser:user];
	}
}

#pragma mark - AddressBookDelegate

- (void)didSelectAddressBookUser:(PFUser *)user
{
	[self addUser:user];
}

#pragma mark - FacebookFriendsDelegate

-(void)selectInvites:(NSMutableArray *)objectIds :(NSMutableArray *)names{
    NSMutableArray *array = group[@"Members"];
    [array addObjectsFromArray:objectIds];
    group[@"Members"] = array;
    //[group[@"Invites"] addObjectsFromArray:objectIds];
    [users addObjectsFromArray:names];
    [userIds removeAllObjects];
    for (PFUser *user in users){
        [userIds addObject:user.objectId];
    }
    [self setObjects:users];
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         SendNotificationAboutInvitingToEvent(group, [names valueForKey:PF_USER_FULLNAME], objectIds);
         [self.tableView reloadData];
     }];
}

#pragma mark - Helper methods

- (void)addUser:(PFUser *)user

{
	if ([userIds containsObject:user.objectId] == NO)
	{
		PeopleSave([PFUser currentUser], user);
		[users addObject:user];
		[userIds addObject:user.objectId];
		[self setObjects:users];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
	if ([sections[section] count] != 0)
	{
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
	}
	else return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index

{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray *userstemp = sections[indexPath.section];
    PeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeopleCell"];
    cell.user = userstemp[indexPath.row];
    if (group[@"Invites"] == nil){
    cell.status = @"";
    } else {
    if ([cell.user[@"letter"] isEqualToString:@"R"]) cell.status = @"Requested";
    if ([cell.user[@"letter"] isEqualToString:@"I"]) cell.status = @"Invited";
    if ([cell.user[@"letter"] isEqualToString:@"M"]) cell.status = @"Coming";
    }
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray *userstemp = sections[indexPath.section];
    PFUser *user = userstemp[indexPath.row];
    if (([group[@"Creator"] isEqualToString:[PFUser currentUser].objectId]) && (user != [PFUser currentUser])) {
        return YES;
    } else if (([group[@"Members"] containsObject:[PFUser currentUser].objectId]) && (user != [PFUser currentUser])){
    return YES;
    } else {
        return NO;
    }
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray *userstemp = sections[indexPath.section];
    PFUser *user = userstemp[indexPath.row];
    [users removeObject:user];
    [userIds removeObject:user.objectId];
    [self setObjects:users];
    
    if (group[@"Identities"]!=nil){
    NSMutableArray *handle = [[NSMutableArray alloc]init];
    [handle addObjectsFromArray:[group[@"Recent"] objectForKey:@"Members"]];
    [handle removeObject:user.objectId];
    [group[@"Recent"] setObject:handle forKey:@"Members"];
    group[@"Affluence"] = @([group[@"Affluence"] integerValue]-1);
        
    NSMutableArray *handlebis = [[NSMutableArray alloc]init];
    handlebis = group[@"Identities"];
    [handlebis removeObject:user.objectId];
    group[@"Identities"] = handlebis;
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
   {
       if (error != nil){
         [ProgressHUD showError:@"Network error."];
       } else {
           //SendNotificationAboutRemovingSomeone(group, user, @"event");
       }
     [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }];
        
    } else {
        NSMutableArray *handle = [[NSMutableArray alloc]init];
        [handle addObjectsFromArray:group[@"Members"]];
        [handle removeObject:user.objectId];
        group[@"Members"] = handle;
        [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
             } else {
                 SendNotificationAboutRemovingSomeone(group, user, @"house");
             }
             [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray *userstemp = sections[indexPath.section];
    userSelected = userstemp[indexPath.row];
    UIActionSheet *action2 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Start chat", @"View profile", nil];
    action2.tag = 7;
    [action2 showFromTabBar:[[self tabBarController] tabBar]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
