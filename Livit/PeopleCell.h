//
//  PeopleCell.h
//  Livit
//
//  Created by Nathan on 1/3/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface PeopleCell : UITableViewCell
@property (nonatomic,strong) PFUser *user;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong,nonatomic) NSString *status;
@end
