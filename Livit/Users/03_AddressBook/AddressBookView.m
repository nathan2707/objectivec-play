//
//  AddressBookView.m
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "FinishController.h"
#import "AddressBookView.h"


@interface AddressBookView()
{
	NSMutableArray *users1;
	NSMutableArray *users2;
    NSMutableArray *selectedUsers;
	NSIndexPath *indexSelected;
}
@end

@implementation AddressBookView

@synthesize delegate;
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Address Book";
	

    if (self.needsToPushForth){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Next" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0,0,50,35);
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = barButton;

    } else if (self.needsToPushBack == NO){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                              action:@selector(actionCancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                                               action:@selector(actionDone)];
    }
    selectedUsers = [[NSMutableArray alloc] init];
	users1 = [[NSMutableArray alloc] init];
	users2 = [[NSMutableArray alloc] init];
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
	ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (granted) [self loadAddressBook];
		});
	});
}

-(void)actionNext{
    NSMutableArray *fbfriendsids = [[NSMutableArray alloc]init];
    for (PFObject *user in selectedUsers){
        [fbfriendsids addObject:user.objectId];
    }
    self.group[@"Invites"] = fbfriendsids;
    FinishController *fc = [[FinishController alloc]init];
    fc.event = self.group;
    [self.navigationController pushViewController:fc animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.needsToPushBack){
        [self.delegate didSelectAddressBookUsers:selectedUsers];
    }
}

#pragma mark - Backend methods
- (void)loadAddressBook

{
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
	{
		CFErrorRef *error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
		ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
		CFIndex personCount = CFArrayGetCount(allPeople);

		[users1 removeAllObjects];
		for (int i=0; i<personCount; i++)
		{
			ABMultiValueRef tmp;
			ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

			NSString *first = @"";
			tmp = ABRecordCopyValue(person, kABPersonFirstNameProperty);
			if (tmp != nil) first = [NSString stringWithFormat:@"%@", tmp];

			NSString *last = @"";
			tmp = ABRecordCopyValue(person, kABPersonLastNameProperty);
			if (tmp != nil) last = [NSString stringWithFormat:@"%@", tmp];

			NSMutableArray *emails = [[NSMutableArray alloc] init];
			ABMultiValueRef multi1 = ABRecordCopyValue(person, kABPersonEmailProperty);
			for (CFIndex j=0; j<ABMultiValueGetCount(multi1); j++)
			{
				tmp = ABMultiValueCopyValueAtIndex(multi1, j);
				if (tmp != nil) [emails addObject:[NSString stringWithFormat:@"%@", tmp]];
			}

			NSMutableArray *phones = [[NSMutableArray alloc] init];
			ABMultiValueRef multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty);
			for (CFIndex j=0; j<ABMultiValueGetCount(multi2); j++)
			{
				tmp = ABMultiValueCopyValueAtIndex(multi2, j);
				if (tmp != nil) [phones addObject:[NSString stringWithFormat:@"%@", tmp]];
			}

			NSString *name = [NSString stringWithFormat:@"%@ %@", first, last];
			[users1 addObject:@{@"name":name, @"emails":emails, @"phones":phones}];
		}
		CFRelease(allPeople);
		CFRelease(addressBook);
		[self loadUsers];
	}
}

- (void)loadUsers
{
	NSMutableArray *emails = [[NSMutableArray alloc] init];
	for (NSDictionary *user in users1)
	{
		[emails addObjectsFromArray:user[@"emails"]];
	}
	PFUser *user = [PFUser currentUser];

	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
	[query1 whereKey:PF_BLOCKED_USER1 equalTo:user];

	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query2 whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
	[query2 whereKey:PF_USER_EMAILCOPY containedIn:emails];
	[query2 orderByAscending:PF_USER_FULLNAME];
	[query2 setLimit:1000];
	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users2 removeAllObjects];
			for (PFUser *user in objects)
			{
				[users2 addObject:user];
				[self removeUser:user[PF_USER_EMAILCOPY]];
			}
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}
- (void)removeUser:(NSString *)email_

{
	NSMutableArray *remove = [[NSMutableArray alloc] init];
	for (NSDictionary *user in users1)
	{
		for (NSString *email in user[@"emails"])
		{
			if ([email isEqualToString:email_])
			{
				[remove addObject:user];
				break;
			}
		}
	}
	for (NSDictionary *user in remove)
	{
		[users1 removeObject:user];
	}
}

#pragma mark - User actions

- (void)actionCancel
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionDone{
    NSMutableArray *handle;
    if (self.group[@"Identities"]) {
        handle = [[NSMutableArray alloc]initWithArray:self.group[@"Identities"]];
        for (PFObject *user in selectedUsers){
            [handle addObject:user.objectId];
        }
        self.group[@"Identities"] = handle;
        [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
     else if (self.group[@"Members"]){
        handle = [[NSMutableArray alloc]initWithArray:self.group[@"Members"]];
    for (PFObject *user in selectedUsers){
        [handle addObject:user.objectId];
        
    }
        self.group[@"Members"] = handle;
        [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
	if (section == 0) return [users2 count];
	if (section == 1) return [users1 count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
	if ((section == 0) && ([users2 count] != 0)) return @"Registered users";
	if ((section == 1) && ([users1 count] != 0)) return @"Non-registered users";
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	if (indexPath.section == 0)
	{
		PFUser *user = users2[indexPath.row];
		cell.textLabel.text = user[PF_USER_FULLNAME];
		cell.detailTextLabel.text = user[PF_USER_EMAILCOPY];
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:user[@"thumbnail"]]];
	}
	if (indexPath.section == 1)
	{
		NSDictionary *user = users1[indexPath.row];
		NSString *email = [user[@"emails"] firstObject];
		NSString *phone = [user[@"phones"] firstObject];
		cell.textLabel.text = user[@"name"];
		cell.detailTextLabel.text = (email != nil) ? email : phone;
	}
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0)
	{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedUsers addObject:users2[indexPath.row]];
        
	}
	if (indexPath.section == 1)
	{
		indexSelected = indexPath;
		[self inviteUser:users1[indexPath.row]];
	}
}

#pragma mark - Invite helper method

- (void)inviteUser:(NSDictionary *)user
{
	if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] != 0))
	{
		UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
											  destructiveButtonTitle:nil otherButtonTitles:@"Email invitation", @"SMS invitation", nil];
		[action showInView:self.view];
	}
	else if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] == 0))
	{
		[self sendMail:user];
	}
	else if (([user[@"emails"] count] == 0) && ([user[@"phones"] count] != 0))
	{
		[self sendSMS:user];
	}
	else [ProgressHUD showError:@"This contact does not have enough information to be invited."];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) return;
	NSDictionary *user = users1[indexSelected.row];
	if (buttonIndex == 0) [self sendMail:user];
	if (buttonIndex == 1) [self sendSMS:user];
}

#pragma mark - Mail sending method

- (void)sendMail:(NSDictionary *)user
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
		[mailCompose setToRecipients:user[@"emails"]];
		[mailCompose setSubject:@""];
		[mailCompose setMessageBody:MESSAGE_INVITE isHTML:YES];
		mailCompose.mailComposeDelegate = self;
		[self presentViewController:mailCompose animated:YES completion:nil];
	}
	else [ProgressHUD showError:@"Please configure your mail first."];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	if (result == MFMailComposeResultSent)
	{
		[ProgressHUD showSuccess:@"Mail sent successfully."];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS sending method
- (void)sendSMS:(NSDictionary *)user
{
	if ([MFMessageComposeViewController canSendText])
	{
		MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
		messageCompose.recipients = user[@"phones"];
		messageCompose.body = MESSAGE_INVITE;
		messageCompose.messageComposeDelegate = self;
		[self presentViewController:messageCompose animated:YES completion:nil];
	}
	else [ProgressHUD showError:@"SMS cannot be sent from this device."];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	if (result == MessageComposeResultSent)
	{
		[ProgressHUD showSuccess:@"SMS sent successfully."];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
