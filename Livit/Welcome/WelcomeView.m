//
//  WelcomeView.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "AFNetworking.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ProgressHUD.h"
#import "SDWebImageManager.h"
#import "AppConstant.h"
#import "image.h"
#import "push.h"

#import "WelcomeView.h"
#import "LoginView.h"
#import "RegisterView.h"

#import "EulaController.h"

@implementation WelcomeView 
BOOL eulaAccepted;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Welcome";
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"EULA"]  isEqual: @YES]){
        eulaAccepted = YES;
    } else {
        eulaAccepted = NO;
        EulaController *newViewController = [[EulaController alloc] init];
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegister:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (eulaAccepted){
	RegisterView *registerView = [[RegisterView alloc] init];
	[self.navigationController pushViewController:registerView animated:YES];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (eulaAccepted){
	LoginView *loginView = [[LoginView alloc] init];
	[self.navigationController pushViewController:loginView animated:YES];
    }
}


#pragma mark - Facebook login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (eulaAccepted){
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    // Next line not working
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
             }
             else [self userLoggedIn:user];
         }
         else [ProgressHUD showError:@"Facebook login error."];
     }];
    }
}


- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,email,name" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             NSDictionary *userData = (NSDictionary *)result;
             [self requestFacebookPicture:user UserData:userData];
         }
         else
         {
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

- (void)requestFacebookPicture:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:link] options:0 progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         if (image != nil)
         {
             [self processFacebook:user UserData:userData Image:image];
         }
         else
         {
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
         }
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData Image:(UIImage *)image
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIImage *picture = ResizeImage(image, 140, 140);
    UIImage *thumbnail = ResizeImage(image, 60, 60);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) NSLog(@"WelcomeView processFacebook picture save error.");
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) NSLog(@"WelcomeView processFacebook thumbnail save error.");
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *name = userData[@"name"];
    NSString *email = userData[@"email"];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (name == nil) name = @"";
    if (email == nil) email = @"";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    user[PF_USER_EMAILCOPY] = email;
    user[PF_USER_FULLNAME] = name;
    user[PF_USER_FULLNAME_LOWER] = [name lowercaseString];
    user[PF_USER_FACEBOOKID] = userData[@"id"];
    user[PF_USER_PICTURE] = filePicture;
    user[PF_USER_THUMBNAIL] = fileThumbnail;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [PFUser logOut];
             [ProgressHUD showError:error.userInfo[@"error"]];
         }
         else [self userLoggedIn:user];
     }];
}

#pragma mark - Helper methods


- (void)userLoggedIn:(PFUser *)user

{
	ParsePushUserAssign();
	[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome %@!", user[PF_USER_FULLNAME]]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
