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
    self.eventImage.image = [UIImage imageNamed:group[@"Category"]];
    self.nameLabel.text = group[@"Name"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eeee, HH:mm a"];
    NSString *dateInString = [dateFormatter stringFromDate:group[@"Date"]];
    self.nameLabel.text = [self.nameLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", dateInString]];
    self.placeLabel.text = group[@"LocationString"];
    self.relationLabel.text = self.number;
    self.relationLabel.text = [self.relationLabel.text stringByAppendingString:@" people that you know"];

}
- (IBAction)actionOui:(id)sender {
    [self.delegate actionAccept:group];
}
- (IBAction)actionNon:(id)sender {
    [self.delegate actionDeny:group];
}

@end
