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
#import "ProgressHUD.h"
#import "UserCell.h"
#import "AppConstant.h"
#import "NavigationController.h"
#import "FacebookFriendsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FacebookFriendsView()
{
    NSMutableArray *users;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation FacebookFriendsView

@synthesize delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    self.title = @"Facebook Friends";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
   //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
                                                                                           action:@selector(actionCompose)];

    users = [[NSMutableArray alloc] init];

    [self loadFacebook];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{    
    NSDictionary *parameters = @{
                                 @"fields": @"name",
                                 @"limit" : @"1500"
                                 };
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             NSMutableArray *fbids = [[NSMutableArray alloc] init];
             NSDictionary *userData = (NSDictionary *)result;
             NSArray *fbusers = [userData objectForKey:@"data"];
             for (NSDictionary *fbuser in fbusers)
             {
                 [fbids addObject:[fbuser valueForKey:@"id"]];
             }
             [self loadUsers:fbids];
         }
         else [ProgressHUD showError:@"Facebook request error."];
     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


- (void)loadUsers:(NSMutableArray *)fbids
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
    [query1 whereKey:PF_BLOCKED_USER1 equalTo:user];
    
    PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
    [query2 whereKey:PF_USER_FACEBOOKID containedIn:fbids];
    [query2 orderByAscending:PF_USER_FULLNAME];
    [query2 setLimit:1000];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [users removeAllObjects];
             [users addObjectsFromArray:objects];
             [self.tableView reloadData];
         }
         else [ProgressHUD showError:@"Network error."];
     }];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionCompose
{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/392279564302271"];
    //optionally set previewImageURL
    //content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`How to implement it?
    [FBSDKAppInviteDialog showFromViewController:self.navigationController withContent:content delegate:self];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [users count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//    
//    PFUser *user = users[indexPath.row];
//    cell.textLabel.text = user[PF_USER_FULLNAME];
//    
//    return cell;
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    [cell bindData:NO:users[indexPath.row]:users];
    return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self dismissViewControllerAnimated:YES completion:^{
        if (delegate != nil) [delegate didSelectFacebookUser:users[indexPath.row]];
    }];
}

#pragma mark - FBSDKAppInviteDialogDelegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    // Intentionally no-op.
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    NSLog(@"app invite error:%@", error);
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sending the invite, please try again later.";
    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
