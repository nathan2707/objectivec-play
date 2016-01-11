//
//  HouseCell.h
//  Livit
//
//  Created by Nathan on 12/12/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
@interface HouseCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *imageHouse;
@property (strong, nonatomic) IBOutlet UILabel *nameHouse;
@property (strong, nonatomic) IBOutlet UILabel *numberEvents;
@property (strong, nonatomic) IBOutlet UILabel *numberMembers;
@property (strong, nonatomic) IBOutlet UIImageView *selectedView;

-(void)setR:(PFObject *)house;
@end
