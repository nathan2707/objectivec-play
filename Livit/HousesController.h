//
//  HousesController.h
//  Livit
//
//  Created by Nathan on 12/12/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface HousesController : UITableViewController
@property (nonatomic,strong) NSMutableArray *houses;
@property (nonatomic,strong) PFObject *event;
@end
