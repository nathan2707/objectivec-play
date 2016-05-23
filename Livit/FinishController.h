//
//  FinishController.h
//  Livit
//
//  Created by Nathan on 12/27/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface FinishController : UITableViewController
@property (nonatomic,strong) PFObject *event;
@property (nonatomic,strong) NSArray *houseNames;
@end
