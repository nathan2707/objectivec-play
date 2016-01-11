//
//  UserCell.m
//  Livit
//
//  Created by Nathan on 10/14/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "UserCell.h"
#import "AppConstant.h"
@implementation UserCell
@synthesize imageUser;
@synthesize nameLabel;
@synthesize user;

- (void)bindData:(NSString*)REQ :(PFUser *)user_ :(NSArray *)users

{
    user = [[NSMutableArray alloc]init];
    [user addObjectsFromArray:users];
    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;
    [imageUser setFile:user_[PF_USER_THUMBNAIL]];
    [imageUser loadInBackground];
   nameLabel.text = user_[PF_USER_FULLNAME];
    if ([self.creator isEqualToString:@"oui"]){
       nameLabel.text = [nameLabel.text stringByAppendingString:@" (creator)"];
    }
    if ([REQ isEqualToString:@"oui"]){
        [self setupView:user_];
    } else if ([REQ isEqualToString:@"da"]){
        [self setupView2:user_];
    }
}

-(void)instaSetUp:(PFUser *)user_ :(NSInteger)rank{
    self.requetteur = user_;
    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;
    [imageUser setFile:user_[PF_USER_THUMBNAIL]];
    [imageUser loadInBackground];
    nameLabel.text = user_[PF_USER_FULLNAME];
    nameLabel.text = [nameLabel.text stringByAppendingString:@" has requested to join this event."];
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:11]];
    
    UIButton *denyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.superview.frame.size.width-75,10,30,30)];
    denyButton.tag = rank;
    [denyButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [denyButton addTarget:self action:@selector(actionNon) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:denyButton];
    
    UIButton *acceptButton = [[UIButton alloc]initWithFrame:CGRectMake(self.superview.frame.size.width-40,10,30,30)];
    [acceptButton setImage:[UIImage imageNamed:@"yesMark"] forState:UIControlStateNormal];
    acceptButton.tag = rank;
    [acceptButton addTarget:self action:@selector(actionOui) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acceptButton];
}



-(void)setupView2: (PFUser *)user_{
    UIButton *acceptButton = [[UIButton alloc]initWithFrame:CGRectMake(375,20,30,30)];
    [acceptButton setImage:[UIImage imageNamed:@"Full Moon Filled-32"] forState:UIControlStateNormal];
    [acceptButton setImage:[UIImage imageNamed:@"Ok-32"] forState:UIControlStateSelected];
    acceptButton.tag = [user indexOfObject:user_];
    [acceptButton addTarget:self action:@selector(actionBla:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acceptButton];

}

-(void)setupView: (PFUser *)user_{
    UIButton *denyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.superview.frame.size.width-90,20,30,30)];
    denyButton.tag = [user indexOfObject:user_];
    [denyButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
    [denyButton addTarget:self action:@selector(actionNon) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:denyButton];
    
    UIButton *acceptButton = [[UIButton alloc]initWithFrame:CGRectMake(self.superview.frame.size.width-40,20,30,30)];
    [acceptButton setImage:[UIImage imageNamed:@"Ok-32"] forState:UIControlStateNormal];
    acceptButton.tag = [user indexOfObject:user_];
    [acceptButton addTarget:self action:@selector(actionOui) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acceptButton];
}

-(void)actionBla:(UIButton*)sender{
    if ([sender isSelected] == YES){
    [self.delegate performSelector:@selector(actionWithdraw:) withObject:[user objectAtIndex:sender.tag]];
    sender.selected = NO;
    } else {
    [self.delegate performSelector:@selector(actionBlatte:) withObject:[user objectAtIndex:sender.tag]];
    sender.selected = YES;
    }
    }
-(void)actionOui{
    [self.delegate performSelector:@selector(actionAccept:)withObject:self.requetteur];
}
-(void)actionNon{
    [self.delegate performSelector:@selector(actionDeny:)withObject:self.requetteur];
}

@end
