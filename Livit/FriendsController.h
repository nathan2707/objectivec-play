//
//  FriendsController.h
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "UserCell.h"

@protocol FacebookFriendsDelegate

- (void)didSelectFacebookUser:(PFUser *)user;
-(void) selectInvites:(NSMutableArray*)objectIds :(NSMutableArray*)users;
@end


@interface FriendsController : UIViewController <CellDelegate, UISearchBarDelegate,FBSDKAppInviteDialogDelegate, UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) NSObject <FacebookFriendsDelegate> *delegate;
@property (nonatomic,strong) PFObject *event;
@end
