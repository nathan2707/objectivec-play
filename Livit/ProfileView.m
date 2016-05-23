//
//  ProfileView.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

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
#import "myButton.h"
#import "push.h"
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
    
    if (![userId isEqualToString:[PFUser currentUser].objectId]){
        UIButton *boutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [boutton addTarget:self action:@selector(actionBlock) forControlEvents:UIControlEventTouchUpInside];
        boutton.frame = CGRectMake(0,0,25,25);
        [boutton setImage:[UIImage imageNamed:@"flag32"] forState:UIControlStateNormal];
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithCustomView:boutton];
        self.navigationItem.rightBarButtonItem = flipButton;
    }
    
    houses = [[NSMutableArray alloc]init];
    events = [[NSMutableArray alloc]init];
    self.textView.userInteractionEnabled = YES;
    self.textView.delegate = self;
    if (![userId isEqualToString:[PFUser currentUser].objectId]){
        
        self.textView.userInteractionEnabled = NO;
        self.textView.selectable = NO;
        self.textView.editable = NO;
    }
    [self loadEvents];
    [self loadHouses];
    [self.tableView setTableHeaderView:viewHeader];
    
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
//-------------------------------------------------------------------------------------------------------------------------------------------------
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
                 [self showUserDetails];
             }
         }
         else [ProgressHUD showError:@"Network error."];
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showUserDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=800&height=800", user[@"facebookId"]]];
    
    
    AFHTTPSessionManager *operation = [AFHTTPSessionManager manager];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        UIImage *image = (UIImage *)responseObject;
        if (image) {
            NSLog(@"Set");
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageUser setImage:image];
            });
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
    }];
    
    self.textView.text = user[@"Description"];
    labelName.text = user[PF_USER_FULLNAME];
}



#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionReport
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil otherButtonTitles:@"Report user", nil];
    action.tag = 1;
    [action showInView:self.view];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Once blocked, this user will never be able to consult your profile again." delegate:self cancelButtonTitle:@"Cancel"
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
            NSLog(@"User %@ reported.",userId);
            PFObject *report = [PFObject objectWithClassName:@"Reports"];
            report[@"object"] = userId;
            report[@"date"] = [NSDate date];
            report[@"reported"] = [PFUser currentUser].objectId;
            [report saveInBackground];

        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex2:(NSInteger)buttonIndex

{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (user != nil)
        {
            NSLog(@"User %@ blocked.",userId);
            PFObject *report = [PFObject objectWithClassName:@"Reports"];
            report[@"object"] = userId;
            report[@"date"] = [NSDate date];
            report[@"reported"] = [PFUser currentUser].objectId;
            [report saveInBackground];

        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 2) return @"Events";
    if (section == 1) return @"Circles";
    //if (section == 1) return @"Tell us";
    if (section == 0) return @"Description";
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (section == 2) return events.count;
    if (section == 1) return houses.count;
    if (section == 0) return 1;
    else return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) return 76;
    if (indexPath.section == 1) return 76;
    else return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section == 0)  return cellDescription;
    //if ((indexPath.section == 1) && (indexPath.row == 0)) return cellReport;
    //if ((indexPath.section == 1) && (indexPath.row == 1)) return cellBlock;
    if (indexPath.section == 1) {
        HouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseCell" forIndexPath:indexPath];
        [cell setR:[houses objectAtIndex:indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    if (indexPath.section == 2)
    {
        NSInteger connection = 0;
//        NSMutableArray *presentFriends = [[NSMutableArray alloc]init];
//        NSMutableArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbfriends"];
//        for (PFObject *group in events){
//            for (NSString *identity in friends){
//                if ( [[group objectForKey:@"Identities"] containsObject:identity]){
//                    connection = connection + 1;
//                    [presentFriends addObject:identity];
//                }
//            }
//        }
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.button1.hidden = YES;
        cell.button2.hidden = YES;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        //cell.delegate = self;
        cell.group = [events objectAtIndex:indexPath.row];
        NSArray *arrayGoing = cell.group[@"Identities"];
        NSArray *arrayRequesting = cell.group[@"Requests"];
        connection = arrayGoing.count + arrayRequesting.count;
        cell.number = [NSString stringWithFormat:@"%li",(long)connection ];
        
        myButton *joinButton = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-65, 22, 30, 30)];
        [joinButton addTarget:self action:@selector(actionJoin:) forControlEvents:UIControlEventTouchUpInside];
        joinButton.tag = indexPath.row;
        
        if ([[cell.group objectForKey:@"Identities"] containsObject:[PFUser currentUser].objectId]){
            [joinButton setImage:[UIImage imageNamed:@"Going" ] forState:UIControlStateNormal];
            joinButton.userId = @"leave";
            if ([[cell.group objectForKey:@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
                joinButton.userInteractionEnabled = NO;
            }
        } else if ([[cell.group objectForKey:@"Requests"] containsObject:[PFUser currentUser].objectId]) {
            [joinButton setImage:[UIImage imageNamed:@"Requested" ] forState:UIControlStateNormal];
            joinButton.userId = @"cancel request";
        } else {
            [joinButton setImage:[UIImage imageNamed:@"Request" ] forState:UIControlStateNormal];
            joinButton.userId = @"join";
        }
        
        [cell addSubview:joinButton];
        
        return cell;
    }
    return nil;
}

-(void)actionJoin:(myButton*)sender{
    EventCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:2]];
    PFUser *usernow = [PFUser currentUser];
    PFObject *event = [events objectAtIndex:sender.tag];
    if ([sender.userId isEqualToString:@"leave"]){
        [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
        sender.userId = @"join";
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Identities"]];
        [handle removeObject:[PFUser currentUser].objectId];
        event[@"Identities"] = handle;
        cell.number = [NSString stringWithFormat: @"%i",(int)cell.number.intValue - 1];
        cell.relationLabel.text = [cell.number stringByAppendingString:@" interested"];
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                NSLog(@"error");
            } else {
                SendNotificationAboutLeaving(event, @"event");
                if ([userId isEqualToString:[PFUser currentUser].objectId]){
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
        
    } else if ([sender.userId isEqualToString:@"cancel request"]){
        sender.userId = @"join";
        [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
        [handle removeObject:[PFUser currentUser].objectId];
        cell.number = [NSString stringWithFormat: @"%i",(int)cell.number.intValue - 1];
        cell.relationLabel.text = [cell.number stringByAppendingString:@" interested"];
        event[@"Requests"] = handle;
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                NSLog(@"error");
            }
        }];
        
    } else {
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        BOOL canJoinDirectly = NO;
        NSArray *channels = [[NSArray alloc] initWithArray:currentInstallation.channels];
        NSArray *househandle = [[NSArray alloc] initWithArray: event[@"Houses"]];
        NSString *houseId;
        for (int i = 0;i<househandle.count;i++){
            houseId = [@"h" stringByAppendingString:househandle[i]];
            if ([channels containsObject:houseId]) canJoinDirectly = YES;
        }
        if ([event[@"Invites"] containsObject:[PFUser currentUser].objectId]){
            canJoinDirectly = YES;
        }
        if (!canJoinDirectly){
            sender.userId = @"cancel request";
            NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
            [handle addObject:[PFUser currentUser].objectId];
            cell.number = [NSString stringWithFormat: @"%i",(int)cell.number.intValue + 1];
            cell.relationLabel.text = [cell.number stringByAppendingString:@" interested"];
            event[@"Requests"] = handle;
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error){
                    NSLog(@"error");
                } else {
                    SendNotificationAboutRequestingToJoin(event, @"event");
                }
            }];
        }else {
            sender.userId = @"leave";
            NSMutableArray *identitiesHandle = [NSMutableArray arrayWithArray:event[@"Identities"]];
            if (![identitiesHandle containsObject:user.objectId]){
                [sender setImage:[UIImage imageNamed:@"Going"] forState:UIControlStateNormal];
                [identitiesHandle addObject:user.objectId];
                cell.number = [NSString stringWithFormat: @"%i",(int)cell.number.intValue + 1];
                cell.relationLabel.text = [cell.number stringByAppendingString:@" interested"];
                event[@"Identities"] = identitiesHandle;
                [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil){
                         [ProgressHUD showError:@"Network error."];
                         NSLog(@"Network error");
                     }
                     NSDictionary *data = @{
                                            @"badge" : @"no",
                                            @"info" : @"GroupsView",
                                            @"alert": [NSString stringWithFormat:@"%@ is going to %@.",usernow[PF_USER_FULLNAME],event[@"Name"]]
                                            };
                     PFPush *push = [[PFPush alloc] init];
                     [push setChannel:[@"h" stringByAppendingString:event.objectId]];
                     [push setData:data];
                     [push sendPushInBackground];
                     
                 }];
            }
        }
    }
    [events replaceObjectAtIndex:sender.tag withObject:event];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionReport];
    //if ((indexPath.section == 1) && (indexPath.row == 1)) [self actionBlock];
    
    if (indexPath.section == 1) {
        GroupsView *detailViewController = [[GroupsView alloc] init];
        //detailViewController.users = [users objectAtIndex:indexPath.row];
        detailViewController.house =[houses objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    if (indexPath.section == 2) {
        GroupSettingsView *detailViewController = [[GroupSettingsView alloc] initWith:[events objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Who you are..."]) {
        textView.text = @"";
    }
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            BOOL check = NO;
            if (cell == self.cellDescription) {
                check = YES;
            }
            
            if (!check) {
                UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
                bgView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
                cell.backgroundView = bgView;
            }
            else{
                UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
                bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                cell.backgroundView = bgView;
            }
            
            
            
        }
        
    }
    
    
}

- (BOOL) textView: (UITextView*) textView
shouldChangeTextInRange: (NSRange) range
  replacementText: (NSString*) text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView{
    user[@"Description"] = textView.text;
    [user saveInBackground];
    
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
            bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            cell.backgroundView = bgView;
            
        }
        
    }
    
    [textView resignFirstResponder];
    
}


@end
