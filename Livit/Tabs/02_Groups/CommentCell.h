//
//  CommentCell.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol CellDelegate2 <NSObject>

-(void)actionProfile:(PFUser*)user_;

@end

@interface CommentCell : UITableViewCell
@property (nonatomic, assign) NSObject<CellDelegate2> *delegate;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property(strong,nonatomic) PFObject *user;
- (void)bindData:(NSString *)comment :(PFUser *)user_;
@end
