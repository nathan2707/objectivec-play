//
//  PeopleCell.m
//  Livit
//
//  Created by Nathan on 1/3/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "PeopleCell.h"
#import "AppConstant.h"

@implementation PeopleCell
@synthesize user,imageUser;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;
    [imageUser setFile:user[PF_USER_THUMBNAIL]];
    [imageUser loadInBackground];
    self.labelName.text = user[PF_USER_FULLNAME];
    self.labelStatus.text = self.status;
    if ([self.status isEqualToString:@"Coming"]) self.labelStatus.textColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    if ([self.status isEqualToString:@"Invited"]) self.labelStatus.textColor = [UIColor blueColor];
    if ([self.status isEqualToString:@"Requested"]) self.labelStatus.textColor = [UIColor orangeColor];
}

@end
