//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "InvitesController.h"
#import "AppConstant.h"
#import "camera.h"
#import "common.h"
#import "image.h"
#import "push.h"
#import "ProfileView.h"
#import "DiscoveryView.h"
#import "SettingsView.h"
#import "BlockedView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "NavigationController.h"
#import "HousesController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView()
@property (strong, nonatomic) IBOutlet UITableViewCell *cellHouses;

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlocked;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDiscovery;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellProfile;
@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogout;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInvites;
@property (strong, nonatomic) IBOutlet UILabel *labelNumberInvites;

@end


@implementation SettingsView
NSMutableArray *houses;
@synthesize viewHeader, imageUser, labelName;
@synthesize cellBlocked, cellPrivacy, cellTerms, cellLogout, cellDiscovery,cellProfile,cellInvites;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
		self.tabBarItem.title = @"Settings";
	}
	return self;
}


- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"Settings";
	self.tableView.tableHeaderView = viewHeader;
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
    
}



-(void)loadGroups{
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Invites" equalTo:[PFUser currentUser].objectId];
    [query orderByAscending:@"timeInterval"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            [ProgressHUD showError:@"Network error."];
        }else{
            self.groups = [[NSMutableArray alloc] initWithArray:objects];
            NSUInteger Y = objects.count;
            PFUser *user = [PFUser currentUser];
            NSUInteger X = Y - [user[@"invites_seen"] integerValue];
            
            self.labelNumberInvites.text = [NSString stringWithFormat:@"%li invites, %li unseen", Y,X ];
            self.labelNumberInvites.textColor = [UIColor redColor];
            [self.labelNumberInvites sizeToFit];
        }
    }];
    
}


- (void)viewDidAppear:(BOOL)animated

{
	[super viewDidAppear:animated];

	if ([PFUser currentUser] != nil)
	{
		[self loadUser];
        [self loadGroups];
        
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

- (void)loadUser

{
	PFUser *user = [PFUser currentUser];

	[imageUser setFile:user[@"thumbnail"]];
	[imageUser loadInBackground];

	labelName.text = user[PF_USER_FULLNAME];
}

#pragma mark - User actions

-(void)actionInvites{
    {
        PFUser *user =[PFUser currentUser];
        user[@"invites_seen"] = @(self.groups.count);
        [user saveInBackground];
        InvitesController *invitesView = [[InvitesController alloc] init];
        invitesView.hidesBottomBarWhenPushed = YES;
        invitesView.groups = self.groups;
        [self.navigationController pushViewController:invitesView animated:YES];
    }
}

- (void)actionBlocked
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BlockedView *blockedView = [[BlockedView alloc] init];
	blockedView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:blockedView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PrivacyView *privacyView = [[PrivacyView alloc] init];
	privacyView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:privacyView animated:YES];
}

-(void)actionProfile
{
    ProfileView *profileView = [[ProfileView alloc] initWith:[[PFUser currentUser]objectId]];
    profileView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileView animated:YES];
}

-(void)actionDiscovery
{
   DiscoveryView *discoveryView = [[DiscoveryView alloc] init];
    discoveryView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:discoveryView animated:YES];
}

- (void)actionTerms

{
	TermsView *termsView = [[TermsView alloc] init];
	termsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:termsView animated:YES];
}


- (void)actionCleanup

{
	imageUser.image = [UIImage imageNamed:@"settings_blank"];
	labelName.text = nil;
}


- (void)actionLogout

{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[PFUser logOut];
		ParsePushUserResign();
		PostNotification(NOTIFICATION_USER_LOGGED_OUT);
		[self actionCleanup];
		LoginUser(self);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PresentPhotoLibrary(self, YES);
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *picture = ResizeImage(image, 280, 280);
	UIImage *thumbnail = ResizeImage(image, 60, 60);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.image = picture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
	[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user[PF_USER_PICTURE] = filePicture;
	user[PF_USER_THUMBNAIL] = fileThumbnail;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 3;
    if (section == 1) return 3;
	if (section == 2) return 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellBlocked;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellPrivacy;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellTerms;
    if ((indexPath.section == 1) && (indexPath.row == 0)) return cellProfile;
    if ((indexPath.section == 1) && (indexPath.row == 1)) return cellDiscovery;
    if ((indexPath.section == 1) && (indexPath.row == 2)) return cellInvites;
    //if ((indexPath.section == 1) && (indexPath.row == 3)) return self.cellHouses;
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellLogout;
    
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionBlocked];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionPrivacy];
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionTerms];
    if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionProfile];
    if ((indexPath.section == 1) && (indexPath.row == 1)) [self actionDiscovery];
    if ((indexPath.section == 1) && (indexPath.row == 2)) [self actionInvites];
    // if ((indexPath.section == 1) && (indexPath.row == 3)) [self actionHouses];
	if ((indexPath.section == 2) && (indexPath.row == 0)) [self actionLogout];
}

-(void)actionHouses{
    HousesController *hc = [[HousesController alloc]init];
    hc.houses = houses;
    [self.navigationController pushViewController:hc animated:YES];
}


@end
