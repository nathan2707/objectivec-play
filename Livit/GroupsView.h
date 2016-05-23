//
//  GroupsView.h
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsView : UITableViewController
@property (strong, nonatomic) PFObject *house;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *events;
@end
