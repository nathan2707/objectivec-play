//
//  TableHeader.m
//  Livit
//
//  Created by Nathan on 1/4/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "TableHeader.h"

@implementation TableHeader

-(void)drawHeader{
    self.logoView.image = [UIImage imageNamed:self.event[@"Category"]];
    self.nameView.text = self.event[@"Name"];
    self.adressLabel.text = self.event[@"LocationString"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eeee, HH:mm a"];
    NSString *timeString = @"";
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:self.event[@"Date"]];
    
    if (timeSince/60 < 1) {
        timeString = [NSString stringWithFormat:@"%is",(int)timeSince];
    }
    else if (timeSince/3600 < 1) {
        timeString = [NSString stringWithFormat:@"%im",(int)timeSince/60];
    }
    else if (timeSince/(3600*24) < 1) {
        timeString = [NSString stringWithFormat:@"%ih",(int)timeSince/3600];
    }
    else{
        timeString = [NSString stringWithFormat:@"%id",(int)timeSince/(3600*24)];
    }
    
    NSString *dateInString = [dateFormatter stringFromDate:self.event[@"Date"]];
    self.dateLabel.text = timeString;
//    [self.contentView setBackgroundColor:[UIColor whiteColor]];
//    [self.contentView setOpaque:NO];
}

@end
