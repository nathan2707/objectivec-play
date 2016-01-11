//
//  BrowserCell.h
//  Livit
//
//  Created by Nathan on 1/4/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "myButton.h"

@interface BrowserCell : UITableViewCell
@property (nonatomic,strong) PFObject *event;
@property (strong, nonatomic) IBOutlet PFImageView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *peopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *inviteLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreHousesLabel;
@property (strong, nonatomic) IBOutlet UILabel *morePeopleLabel;
@property (strong, nonatomic) IBOutlet PFImageView *imageHouse1;
@property (strong, nonatomic) IBOutlet PFImageView *imageHouse2;
@property (strong, nonatomic) IBOutlet PFImageView *imageHouse3;
@property (strong, nonatomic) IBOutlet PFImageView *imageHouse4;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser1;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser2;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser3;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser4;
@property (strong, nonatomic) IBOutlet myButton *requestButton;

@end
