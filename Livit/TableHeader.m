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
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"eeee, HH:mm a"];
//    NSString *dateInString = [dateFormatter stringFromDate:self.event[@"Date"]];
    NSString *timeString = @"";
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:self.event[@"Date"]];
    double absoluteTime = fabs(timeSince);
    
    if (absoluteTime/60 < 1) {
        timeString = [NSString stringWithFormat:@"%is",(int)absoluteTime];
    }
    else if (absoluteTime/3600 < 1) {
        timeString = [NSString stringWithFormat:@"%im",(int)absoluteTime/60];
    }
    else if (absoluteTime/(3600*24) < 1) {
        timeString = [NSString stringWithFormat:@"%ih",(int)absoluteTime/3600];
    }
    else{
        timeString = [NSString stringWithFormat:@"%id",(int)absoluteTime/(3600*24)];
    }
    if (timeSince < 0){
        self.dateLabel.text = [NSString stringWithFormat:@"in %@",timeString];
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"%@ ago",timeString];
    }
}

@end
