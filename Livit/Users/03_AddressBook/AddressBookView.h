//
//  AddressBookView.m
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Parse/Parse.h>

@protocol AddressBookDelegate

- (void)didSelectAddressBookUser:(PFUser *)user;
-(void) didSelectAddressBookUsers:(NSMutableArray*)array;
@end

@interface AddressBookView : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) NSObject <AddressBookDelegate> *delegate;
@property (nonatomic,strong) PFObject *group;
@property (nonatomic,assign) BOOL needsToPushBack;
@property (nonatomic,assign) BOOL needsToPushForth;
@end
