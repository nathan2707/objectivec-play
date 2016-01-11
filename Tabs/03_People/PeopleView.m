//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
#import "FacebookFriendsView.h"
#import "NavigationController.h"

@interface PeopleView()
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
    for (PFUser *requester in self.requesters){
        requester[@"letter"] = @"R";
    }
    for (PFUser *inviter in self.invited){
        inviter[@"letter"] = @"I";
    }
    for (PFUser *member in self.usersCurrent){
        member[@"letter"] = @"M";
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
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (sections != nil) [sections removeAllObjects];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
	sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSUInteger i=0; i<sectionTitlesCount; i++)
	{
		[sections addObject:[NSMutableArray array]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		PFUser *user1 = (PFUser *)obj1;
		PFUser *user2 = (PFUser *)obj2;
		return [user1[PF_USER_FULLNAME] compare:user2[PF_USER_FULLNAME]];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *object in sorted)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(fullname)];
		[sections[section] addObject:object];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[users removeAllObjects];
	[userIds removeAllObjects];
	[sections removeAllObjects];
	[self.tableView reloadData];
}

- (void)actionAdd

{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
								   otherButtonTitles:@"Search user", @"Select users", @"Address Book", @"Facebook Friends", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (actionSheet.numberOfButtons == 3){
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
        
    } else {
    
    
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		skipLoading = YES;
		if (buttonIndex == 0)
		{
			SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
			selectSingleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 1)
		{
			SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
			selectMultipleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 2)
		{
			AddressBookView *addressBookView = [[AddressBookView alloc] init];
			addressBookView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addressBookView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 3)
		{
			FacebookFriendsView *facebookFriendsView = [[FacebookFriendsView alloc] init];
			facebookFriendsView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:facebookFriendsView];
			[self presentViewController:navController animated:YES completion:nil];
		}
	}
    
    }
    
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSMutableArray *)users_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (PFUser *user in users_)
	{
		[self addUser:user];
	}
}

#pragma mark - AddressBookDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectAddressBookUser:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - FacebookFriendsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectFacebookUser:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addUser:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections[section] count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([sections[section] count] != 0)
	{
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
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
    if ([cell.user[@"letter"] isEqualToString:@"R"]) cell.status = @"requested";
    if ([cell.user[@"letter"] isEqualToString:@"I"]) cell.status = @"invited";
    if ([cell.user[@"letter"] isEqualToString:@"M"]) cell.status = @"coming";
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([[[PFUser currentUser] objectId] isEqualToString:group[@"Creator"]]) return YES;
	return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
	NSMutableArray *userstemp = sections[indexPath.section];
	PFUser *user = userstemp[indexPath.row];
	[users removeObject:user];
	[userIds removeObject:user.objectId];
	[self setObjects:users];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:@"user" equalTo:user.objectId];
    [query whereKey:@"objectId" equalTo:group[@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *object in objects) {
                 [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) [ProgressHUD showError:@"Network error."];
                  }];
             }
         }
         else [ProgressHUD showError:@"Network error."];
     }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query2 whereKey:@"objectId" equalTo:group[@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *object in objects) {
                 [object[@"members"] removeObject:user];
                 [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) [ProgressHUD showError:@"Network error."];
                  }];
             }
         }
         else [ProgressHUD showError:@"Network error."];
     }];
    
    
    group[@"Affluence"] = @([group[@"Affluence"] integerValue]-1);
    [group[@"Identities"] removeObjectAtIndex:indexPath.row];

    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
   {
     if (error != nil) [ProgressHUD showError:@"Network error."];
     [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray *userstemp = sections[indexPath.section];
    userSelected = userstemp[indexPath.row];
    UIActionSheet *action2 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Start chat", @"View profile", nil];
    [action2 showFromTabBar:[[self tabBarController] tabBar]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
