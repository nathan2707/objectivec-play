//
//  EventCell.h
//  Livit
//
//  Created by Nathan on 12/11/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "myButton.h"
@protocol EventCellDelegate <NSObject>

-(void)actionAccept:(PFObject*)group_;
-(void)actionDeny:(PFObject*)group_;
@end



@interface EventCell : UITableViewCell

@property (nonatomic, assign) NSObject<EventCellDelegate> *delegate;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet PFImageView *eventImage;

@property (strong, nonatomic) IBOutlet UILabel *relationLabel;

@property (nonatomic,strong) PFObject *group;
@property (nonatomic, strong) NSString *number;
@property (strong, nonatomic) IBOutlet myButton *placeButton;

@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;


@end
