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
@property (strong, nonatomic) IBOutlet myButton *requestButton;
@property (strong, nonatomic) IBOutlet UILabel *houseLabel;

@end
