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
#import "AFNetworking.h"
#import "AppConstant.h"
#import "common.h"
#import "EventCell.h"
#import "ProfileView.h"
#import "NavigationController.h"
#import "HouseCell.h"
#import "image.h"
#import "GroupSettingsView.h"
#import "GroupsView.h"

@interface ProfileView() <UITextViewDelegate>
{
	NSString *userId;
	PFUser *user;
    NSMutableArray *events;
    NSMutableArray *houses;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellReport;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlock;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDescription;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end


@implementation ProfileView

@synthesize viewHeader, imageUser, labelName;
@synthesize cellReport, cellBlock, cellDescription;


- (id)initWith:(NSString *)userId_

{
	self = [super init];
	userId = userId_;
	return self;
}

- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"Profile";
    houses = [[NSMutableArray alloc]init];
    events = [[NSMutableArray alloc]init];
    self.textView.userInteractionEnabled = YES;
    if (userId != [PFUser currentUser].objectId) self.textView.userInteractionEnabled = NO;
    [self loadEvents];
    [self loadHouses];
	self.tableView.tableHeaderView = viewHeader;
    [self.tableView registerNib:[UINib nibWithNibName:@"HouseCell" bundle:nil] forCellReuseIdentifier:@"HouseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
//	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
//	imageUser.layer.masksToBounds = YES;
}


- (void)viewDidAppear:(BOOL)animated

{
	[super viewDidAppear:animated];

	[self loadUser];
}

-(void)loadEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Identities" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
    }];
}

-(void)loadHouses {
    PFQuery *query = [PFQuery queryWithClassName:@"Houses"];
    [query whereKey:@"Members" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [houses addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
    }];
}



#pragma mark - Backend actions


- (void)loadUser

{
	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_OBJECTID equalTo:userId];
    
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			user = [objects firstObject];
			if (user != nil)
			{
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=800&height=800", user[@"facebookId"]]]];
     
                
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.responseSerializer = [AFImageResponseSerializer serializer];
            
                
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     UIImage *image = (UIImage *)responseObject;
                     
                     [imageUser setImage:image];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     
                     [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
                 }];
                [[NSOperationQueue mainQueue] addOperation:operation];
				labelName.text = user[PF_USER_FULLNAME];
			}
		}
		else [ProgressHUD showError:@"Network error."];
	}];
    
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionReport
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil otherButtonTitles:@"Report user", nil];
	action.tag = 1;
	[action showInView:self.view];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Block user" otherButtonTitles:nil];
	action.tag = 2;
	[action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (actionSheet.tag == 1) [self actionSheet:actionSheet clickedButtonAtIndex1:buttonIndex];
	if (actionSheet.tag == 2) [self actionSheet:actionSheet clickedButtonAtIndex2:buttonIndex];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex1:(NSInteger)buttonIndex

{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (user != nil)
		{
			ActionPremium(self);
		}
	}
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex2:(NSInteger)buttonIndex

{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (user != nil)
		{
			ActionPremium(self);
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
	return 4;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 3) return @"Events";
    if (section == 2) return @"Houses";
    if (section == 1) return @"Tell us";
    if (section == 0) return @"Description";
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
     if (section == 3) return events.count;
     if (section == 2) return houses.count;
	 if (section == 1) return 2;
     else return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) return 76;
    if (indexPath.section == 2) return 76;
       else return 50;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section == 0)  return cellDescription;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellReport;
	if ((indexPath.section == 1) && (indexPath.row == 1)) return cellBlock;
    if (indexPath.section == 2) {
        HouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseCell" forIndexPath:indexPath];
            [cell setR:[houses objectAtIndex:indexPath.row]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
        }
    if (indexPath.section == 3)
    {
        NSInteger connection = 0;
        NSMutableArray *presentFriends = [[NSMutableArray alloc]init];
        NSMutableArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbfriends"];
        for (PFObject *group in events){
            for (NSString *identity in friends){
                if ( [[group objectForKey:@"Identities"] containsObject:identity]){
                    connection = connection + 1;
                    [presentFriends addObject:identity];
                }
            }
        }
        
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.number = [NSString stringWithFormat:@"%li",(long)connection ];
        cell.button1.hidden = YES;
        cell.button2.hidden = YES;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        //cell.delegate = self;
        cell.group = [events objectAtIndex:indexPath.row];
        return cell;
        
    }

	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionReport];
	if ((indexPath.section == 1) && (indexPath.row == 1)) [self actionBlock];
    
    if (indexPath.section == 2) {
        GroupsView *detailViewController = [[GroupsView alloc] init];
        //detailViewController.users = [users objectAtIndex:indexPath.row];
        detailViewController.house =[houses objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    if (indexPath.section == 3) {
        GroupSettingsView *detailViewController = [[GroupSettingsView alloc] initWith:[events objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    user[@"Description"] = textView.text;
    [user saveInBackground];
}

@end
