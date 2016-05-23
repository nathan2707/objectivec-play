//
//  RecentView.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"

@interface RecentView : UITableViewController <UIActionSheetDelegate, SelectSingleDelegate, SelectMultipleDelegate, AddressBookDelegate, FacebookFriendsDelegate>

- (void)loadRecents;

@end
