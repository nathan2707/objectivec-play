//
//  EventCell.m
//  Livit
//
//  Created by Nathan on 12/11/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "EventCell.h"

@implementation EventCell
@synthesize group;


- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //self.eventImage.image = [UIImage imageNamed:group[@"Category"]];
    
    self.eventImage.layer.cornerRadius = self.eventImage.frame.size.width/2;
    self.eventImage.layer.masksToBounds = YES;
    [self.eventImage setFile:group[@"Picture"]];
    [self.eventImage loadInBackground];
    self.nameLabel.text = group[@"Name"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eeee, HH:mm a"];
    NSString *dateInString = [dateFormatter stringFromDate:group[@"Date"]];
    self.dateLabel.text = dateInString;
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    if ([group[@"timeInterval"] doubleValue] >= NSTimeIntervalSince1970){
        [self.dateLabel setTextColor:[UIColor redColor]];
    } 
    [self.placeButton setTitle:[group[@"Location"] objectForKey:@"string"] forState:UIControlStateNormal];
    self.relationLabel.text = self.number;
    self.relationLabel.text = [self.relationLabel.text stringByAppendingString:@" interested"];

}
- (IBAction)actionOui:(id)sender {
    [self.delegate actionAccept:group];
}
- (IBAction)actionNon:(id)sender {
    [self.delegate actionDeny:group];
}

@end
