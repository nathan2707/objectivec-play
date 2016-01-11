//
//  FriendsController.m
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "FriendsController.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "NavigationController.h"
#import "FacebookFriendsView.h"
#import "FinishController.h"

@interface FriendsController ()
{
    NSMutableArray *users;
    NSMutableArray *selection;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *searchResults;
@end

@implementation FriendsController
@synthesize delegate;

-(void)actionBlatte:(PFUser *)user_{
    [selection addObject:user_];
}
-(void)actionWithdraw:(PFUser *)user_{
    [selection removeObject:user_];
}
-(void)actionInvite{
    if (selection.count !=0){
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSMutableArray *objectIds = [[NSMutableArray alloc]init];
    for (int i =0;i<selection.count;i++){
        [names addObject:[[selection objectAtIndex:i] objectForKey:@"fullname"]];
        [objectIds addObject:[[selection objectAtIndex:i] objectId]];
    }
        [self.delegate performSelector:@selector(selectInvites::) withObject:objectIds withObject:selection];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self actionInvite];
            }
    [super viewWillDisappear:animated];
}

#pragma mark - UISearchBar Delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length > 0)
    {
        [self.tableView setHidden:NO];
        [self.searchResults removeAllObjects];
        for (int i = 0; i < users.count; i++){
            if ([[[users objectAtIndex:i] objectForKey:@"fullname_lower"] containsString:self.searchBar.text]){
                [self.searchResults addObject:[users objectAtIndex:i]];
            }
        }
        [self.tableView reloadData];
    }
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.tableView setHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    NSMutableArray *fbfriendsids = [[NSMutableArray alloc]init];
    for (PFObject *user in users){
        [fbfriendsids addObject:user.objectId];
    }
    [[NSUserDefaults standardUserDefaults]setObject:fbfriendsids forKey:@"fbfriends"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)viewDidLoad

{
    [super viewDidLoad];
    self.searchResults = [[NSMutableArray alloc]init];
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    
    if (self.navigationController.viewControllers.count == 4){
    
    if ( self == [self.navigationController.viewControllers objectAtIndex:3] ){
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0,50,35);
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    self.title = @"Invites";
    }
    } else {
        
    self.title = @"Facebook Friends";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(actionInvite)];
    [self.navigationItem setBackBarButtonItem:backButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
                                                                                action:@selector(actionCompose)];
    }
    
    selection = [[NSMutableArray alloc] init];
    users = [[NSMutableArray alloc] init];
    
    [self loadFacebook];
}

#pragma mark - Backend methods


- (void)loadFacebook

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


- (void)actionCancel
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionNext{
    NSMutableArray *fbfriendsids = [[NSMutableArray alloc]init];
    for (PFObject *user in selection){
        [fbfriendsids addObject:user.objectId];
    }
    self.event[@"Invites"] = fbfriendsids;
    FinishController *fc = [[FinishController alloc]init];
    fc.event = self.event;
    [self.navigationController pushViewController:fc animated:YES];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (self.searchBar.text.length > 0){
        return self.searchResults.count;
    } else {
    return [users count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    //
    //    PFUser *user = users[indexPath.row];
    //    cell.textLabel.text = user[PF_USER_FULLNAME];
    //
    //    return cell;
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    NSLog(@"%lu",(unsigned long)self.searchResults.count);
    if (self.searchBar.text.length > 0){
        [cell bindData:@"da":self.searchResults[indexPath.row]: self.searchResults];
    }else{
        [cell bindData:@"da":users[indexPath.row]:users];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
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
