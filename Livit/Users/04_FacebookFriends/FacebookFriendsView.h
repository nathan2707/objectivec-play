//
//  FacebookFriendsView.h
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@protocol FacebookFriendsDelegate

- (void)didSelectFacebookUser:(PFUser *)user;

@end

@interface FacebookFriendsView : UITableViewController <UISearchBarDelegate,FBSDKAppInviteDialogDelegate>

@property (nonatomic, assign) IBOutlet id<FacebookFriendsDelegate>delegate;

@end
