//
//  group.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>

void			RemoveGroupMembers		(PFUser *user1, PFUser *user2);

void			RemoveGroupMember		(PFObject *group, PFUser *user);
void			RemoveGroupItem			(PFObject *group);
