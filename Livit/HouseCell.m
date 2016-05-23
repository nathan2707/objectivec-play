//
//  HouseCell.m
//  Livit
//
//  Created by Nathan on 12/12/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "HouseCell.h"

@implementation HouseCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

-(void)setR:(PFObject *)house{

    [self.imageHouse setFile:[house objectForKey:@"Thumbnail"]];
    [self.imageHouse loadInBackground];
    
//    NSArray *events = [[NSArray alloc]initWithArray:[house objectForKey:@"Events"]];
//    NSString *string1 = [NSString stringWithFormat:@"%li",events.count];
//    string1 = [string1 stringByAppendingString:@" events this week"];
//    self.numberEvents.text = string1;
    
    NSArray *members = [[NSArray alloc]initWithArray:[house objectForKey:@"Members"]];
    NSString *string2 = [NSString stringWithFormat:@"%lu %@",(unsigned long)members.count, (members.count > 1) ? @"Members" : @"Member" ];
    self.numberMembers.text = string2;
   
    self.nameHouse.text = [house objectForKey:@"Name"];
}

@end
