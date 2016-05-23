//
//  UserCell.h
//  Livit
//
//  Created by Nathan on 10/14/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol CellDelegate <NSObject>

-(void)actionAccept:(PFUser*)user_;
-(void)actionDeny:(PFUser*)user_;
-(void)actionBlatte:(PFUser*)user_;
-(void)actionWithdraw:(PFUser*)user_;
@end


@interface UserCell : UITableViewCell
- (void)bindData:(NSString*)REQ :(PFUser *)user_ :(NSArray*)users;
-(void)instaSetUp:(PFUser *)user_ :(NSInteger)rank;
-(void)actionOui;
-(void)actionNon;
@property (nonatomic, assign) NSObject<CellDelegate> *delegate;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong,nonatomic) NSMutableArray *user;
@property (strong,nonatomic) NSString *creator;
@property (strong, nonatomic) PFUser *requetteur;
@end
