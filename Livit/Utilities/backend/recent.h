//
//  recent.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>

NSString*		StartPrivateChat		(PFUser *user1, PFUser *user2);
NSString*		StartMultipleChat		(NSMutableArray *users);

void			CreateRecentItem		(PFUser *user, NSString *groupId, NSArray *members, NSString *description, NSString *category, PFObject *event);

void			UpdateRecentCounter		(NSString *groupId, NSInteger amount, NSString *lastMessage);
void			ClearRecentCounter		(NSString *groupId);

void			DeleteRecentItems		(PFUser *user1, PFUser *user2);
