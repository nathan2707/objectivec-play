//
//  CommentCell.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "CommentCell.h"
#import "AppConstant.h"
@implementation CommentCell
@synthesize imageUser;
@synthesize commentLabel;


- (IBAction)showProfile:(id)sender {
    [self.delegate performSelector:@selector(actionProfile:)withObject:self.user];
}

- (void)bindData:(NSString *)comment :(PFUser*)user

{
    self.user =user;
    [self.nameButton setTitle:user[PF_USER_FULLNAME_LOWER] forState:UIControlStateNormal];
    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;
    [imageUser setFile:user[PF_USER_THUMBNAIL]];
    [imageUser loadInBackground];
    commentLabel.text = comment;
    
}

@end
