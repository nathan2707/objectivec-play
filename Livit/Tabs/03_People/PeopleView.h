//
//  PeopleView.h
//  Livit
//
//  Created by Nathan on 10/14/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"

@interface PeopleView : UITableViewController <UIActionSheetDelegate, SelectSingleDelegate, SelectMultipleDelegate, AddressBookDelegate, FacebookFriendsDelegate>
@property (nonatomic,strong) NSMutableArray *usersCurrent;
@property (nonatomic,strong) NSMutableArray *requesters;
@property (nonatomic,strong) NSMutableArray *invited;
@property (nonatomic, strong) PFObject *group;
@end
