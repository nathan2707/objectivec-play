//
//  GroupsView.m
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"
#import "AppConstant.h"
#import "common.h"
#import "group.h"
#import "push.h"
#import "recent.h"
#import "GalleryView.h"
#import "GroupsView.h"
#import "CreateGroupView.h"
#import "GroupSettingsView.h"
#import "NavigationController.h"
#import "UserCell.h"
#import "EventCell.h"
#import "myButton.h"
#import "FriendsController.h"
#import <MapKit/MapKit.h>
#import "PeopleView.h"
#import "camera.h"
#import "image.h"
#import "AddressBookView.h"

@interface GroupsView()<CellDelegate, FacebookFriendsDelegate,UIActionSheetDelegate,AddressBookDelegate>
{
    BOOL cameraOrPicture;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet PFImageView *houseImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMotto;
@property (strong, nonatomic) IBOutlet UILabel *labelMotto;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UIButton *leaveHouseButton;
@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UITableView *requestTableView;
@property (strong, nonatomic) IBOutlet PFImageView *backgroundView;

@end


@implementation GroupsView
@synthesize users, events;
NSMutableArray *requestUsers;
BOOL onefinished;

-(void)loadEvents{
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Houses" equalTo:self.house.objectId];
    [query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events removeAllObjects];
            [events addObjectsFromArray:objects];
            [self loadUsers];
        }
    }];
}

-(void)loadUsers{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    NSArray *array = [NSArray arrayWithArray:[self.house objectForKey:@"Members"]];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil){
            [self.users removeAllObjects];
            [self.users addObjectsFromArray:objects];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    onefinished = NO;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.title = [self.house objectForKey:@"Name"];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    [self.requestTableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadEvents) forControlEvents:UIControlEventValueChanged];
    
    self.textView.text = [self.house objectForKey:@"Motto"];
    self.nameLabel.text = [self.house objectForKey:@"Name"];
    [self.houseImage setFile:[self.house objectForKey:@"Picture"]];
    self.houseImage.layer.cornerRadius = self.houseImage.frame.size.width/2;
    self.houseImage.layer.masksToBounds = YES;
    [self.houseImage loadInBackground];
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionCamera:)];
    self.houseImage.tag = 0;
    [self.houseImage addGestureRecognizer:tap0];
    self.houseImage.userInteractionEnabled = YES;
    
    if ([self.house objectForKey:@"Background"]) {
        [self.backgroundView setFile:[self.house objectForKey:@"Background"]];
    } else {
        [self.backgroundView setFile:[self.house objectForKey:@"Picture"]];
    }
    
    [self.backgroundView loadInBackground];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionCamera:)];
    self.backgroundView.tag = 1;
    [self.backgroundView addGestureRecognizer:tap1];
    self.backgroundView.userInteractionEnabled = YES;
    
    NSArray *array = [self.house objectForKey:@"thumbnailFiles"];
    NSString *string = [NSString stringWithFormat:@"%li",array.count];
    self.labelMotto.text = [string stringByAppendingString:@" elements"];
    self.numberLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)array.count, (array.count > 1) ? @"Photos" : @"Photo" ];
    self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.users.count, (self.users.count > 1) ? @"Members" : @"Member" ];
    if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]){
        requestUsers = [[NSMutableArray alloc]init];
        [self loadRequestUsers];
        
        [self.leaveHouseButton setTitle:@"Joined" forState:UIControlStateNormal];
        [self.leaveHouseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.leaveHouseButton.layer.cornerRadius = 3;
        [[self.leaveHouseButton layer] setBorderWidth:0.5f];
        [self.leaveHouseButton setBackgroundColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1]];
        [[self.leaveHouseButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        
    } else {
        [self.leaveHouseButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.leaveHouseButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
        self.leaveHouseButton.layer.cornerRadius = 3;
        [[self.leaveHouseButton layer] setBorderWidth:0.5f];
        [[self.leaveHouseButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
    }
}

-(void)loadRequestUsers{
    [requestUsers removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" containedIn:self.house[@"Requests"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [requestUsers addObjectsFromArray:objects];
         }
         else [ProgressHUD showError:@"Network error."];
         self.requestTableView.delegate = self;
         onefinished = YES;
         [self.requestTableView reloadData];
         self.requestTableView.frame = CGRectMake(0,0,self.view.frame.size.width, requestUsers.count * 50);
         [self.view addSubview:self.requestTableView];
     }];
}




- (IBAction)leaveHouse:(id)sender {
    
    if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]==NO){
        
        if ([[self.house objectForKey:@"Privacy"] isEqualToString:@"yes"]){
            
            if ([[self.house objectForKey:@"Requests"] containsObject:[PFUser currentUser].objectId]){
                
                [self.leaveHouseButton setTitle:@"Join" forState:UIControlStateNormal];
                [self.leaveHouseButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
                [self.leaveHouseButton setBackgroundColor:[UIColor whiteColor]];
                self.leaveHouseButton.layer.cornerRadius = 3;
                [[self.leaveHouseButton layer] setBorderWidth:0.5f];
                [[self.leaveHouseButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
                [self.house[@"Members"] removeObject:[PFUser currentUser].objectId];
                [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (succeeded == NO){
                        NSLog(@"error");
                    }
                    [self.tableView reloadData];
                }];
                
            }else{
                
                [self.leaveHouseButton setTitle:@"Requested" forState:UIControlStateNormal];
                [self.leaveHouseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                self.leaveHouseButton.layer.cornerRadius = 3;
                [[self.leaveHouseButton layer] setBorderWidth:0.5f];
                [self.leaveHouseButton setBackgroundColor:[UIColor lightGrayColor]];
                [[self.leaveHouseButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
                [self.house[@"Requests"] addObject:[PFUser currentUser].objectId];
                [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (succeeded == NO){
                        NSLog(@"error");
                    } else {
                        SendNotificationAboutRequestingToJoin(self.house, @"house");
                    }
                }];
            }
            
        } else {
            
            [self.leaveHouseButton setTitle:@"Join" forState:UIControlStateNormal];
            [self.leaveHouseButton setBackgroundColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1]];
            self.leaveHouseButton.layer.cornerRadius = 3;
            [[self.leaveHouseButton layer] setBorderWidth:0.5f];
            [self.leaveHouseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[self.leaveHouseButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
            
            [self.house[@"Members"] addObject:[PFUser currentUser].objectId];
            [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded == NO){
                    NSLog(@"error");
                } else {
                    SendNotificationAboutAcceptingInvitation(self.house, @"house");
                }
                [self.tableView reloadData];
            }];
        }
        
    } else {
        [self.leaveHouseButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.leaveHouseButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
        [self.leaveHouseButton setBackgroundColor:[UIColor whiteColor]];
        self.leaveHouseButton.layer.cornerRadius = 3;
        [[self.leaveHouseButton layer] setBorderWidth:0.5f];
        [[self.leaveHouseButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        NSMutableArray *handle = self.house[@"Members"];
        [handle removeObject:[PFUser currentUser].objectId];
        self.house[@"Members"] = handle;
        [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded == NO){
                NSLog(@"error");
            } else {
                SendNotificationAboutLeaving(self.house, @"house");
            }
            [self.tableView reloadData];
        }];
    }
}



- (void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser] != nil)
    {
        NSArray *arrayphotos = [self.house objectForKey:@"thumbnailFiles"];
        NSArray *arraypeople = [self.house objectForKey:@"Members"];
        self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)arraypeople.count, (arraypeople.count > 1) ? @"Members" : @"Member" ];
        self.numberLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)arrayphotos.count, (arrayphotos.count > 1) ? @"Photos" : @"Photo" ];
    }
    else LoginUser(self);
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    if (tableView == self.requestTableView) return 1;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((section == 0) && (tableView != self.requestTableView)) return @"Recent events";
    else{
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (tableView == self.requestTableView) return requestUsers.count;
    if (section == 0) return events.count;
    
    return 0;
}

-(void)actionItinerary:(myButton*)sender{
    double latitude = [[sender.coordinates1 objectForKey:@"lat"] doubleValue];
    double longitude = [[sender.coordinates1 objectForKey:@"long"] doubleValue];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:sender.userId];
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if (tableView == self.requestTableView){
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        if (onefinished){
            [cell instaSetUp:requestUsers[indexPath.row]:indexPath.row];
            cell.delegate = self;
        }
        return cell;
    }
    else {
        if (indexPath.section == 0){
            EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
            cell.group = [events objectAtIndex:indexPath.row];
            
            [cell.button1 setHidden:YES];
            cell.button1.enabled = NO;
            [cell.button2 setHidden:YES];
            cell.button2.enabled = NO;
            
            [cell.placeButton addTarget:self action:@selector(actionItinerary:) forControlEvents:UIControlEventTouchUpInside];
            if (![[events objectAtIndex:indexPath.row] objectForKey:@"Location"] || ![[[events objectAtIndex:indexPath.row] objectForKey:@"Location"] objectForKey:@"long"] || ![[[events objectAtIndex:indexPath.row] objectForKey:@"Location"] objectForKey:@"lat"]) {
                NSLog(@"Shoot!!");
            }
            else{
                cell.placeButton.coordinates1 = @{@"lat":[[[events objectAtIndex:indexPath.row] objectForKey:@"Location"] objectForKey:@"lat"], @"long":[[[events objectAtIndex:indexPath.row] objectForKey:@"Location"] objectForKey:@"long"]};
            }
            
            cell.placeButton.userId = [[events objectAtIndex:indexPath.row] objectForKey:@"Name"];
            
            
            myButton *joinButton = [[myButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-55, 15, 30, 30)];
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
        else{
            return nil;
        }
    }
}

-(void)actionJoin:(myButton*)sender{
    PFObject *event = [events objectAtIndex:sender.tag];
    PFUser *user = [PFUser currentUser];
    if ([sender.userId isEqualToString:@"leave"]){
        [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
        sender.userId = @"join";
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Identities"]];
        [handle removeObject:[PFUser currentUser].objectId];
        event[@"Identities"] = handle;
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                NSLog(@"error");
            } else {
                SendNotificationAboutLeaving(event, @"event");
            }
        }];
        
    } else if ([sender.userId isEqualToString:@"cancel request"]){
        sender.userId = @"join";
        [sender setImage:[UIImage imageNamed:@"Request"] forState:UIControlStateNormal];
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
        [handle removeObject:[PFUser currentUser].objectId];
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
                [sender setTitle:@"Joined" forState:UIControlStateNormal];
                [identitiesHandle addObject:user.objectId];
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
                                            @"alert": [NSString stringWithFormat:@"%@ is going to %@.",user[PF_USER_FULLNAME],event[@"Name"]]
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



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0) return 60;
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section ==0){
        GroupSettingsView *gsv = [[GroupSettingsView alloc]initWith:[events objectAtIndex:indexPath.row]];
        gsv.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gsv animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)actionAccept:(PFUser*)user_{
    [requestUsers removeObject:user_];
    self.requestTableView.frame = CGRectMake(0,0,self.view.frame.size.width, requestUsers.count * 50);
    self.house[@"Requests"] = requestUsers;
    [self.users addObject:user_];
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:self.house[@"Members"]];
    [array addObject:user_.objectId];
    self.house[@"Members"] = array;
    [self.house saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView reloadData];
         [self.requestTableView reloadData];
         self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)array.count, (array.count > 1) ? @"Members" : @"Member" ];
         SendNotificationAboutAcceptingRequest(self.house, user_, @"house");
     }];
}


-(void)actionDeny:(PFUser*)user_{
    [requestUsers removeObject:user_];
    self.requestTableView.frame = CGRectMake(0,0,self.view.frame.size.width, requestUsers.count * 50);
    self.house[@"Requests"] = requestUsers;
    [self.house saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView reloadData];
         [self.requestTableView reloadData];
     }];
}

-(void)actionAdd{
    if ([self.house[@"Members"] containsObject:[[PFUser currentUser] objectId]]){
        
        PFUser *user = [PFUser currentUser];
        if (user[@"PicURL"] != nil){
            FriendsController *facebookFriendsView = [[FriendsController alloc] init];
            facebookFriendsView.delegate = self;
            [self.navigationController pushViewController:facebookFriendsView animated:YES];
        }else {
            AddressBookView *abv = [[AddressBookView alloc]init];
            abv.delegate = self;
            abv.needsToPushBack = YES;
            abv.needsToPushForth = NO;
            [self.navigationController pushViewController:abv animated:YES];
        }
    }
    
}

-(void)didSelectAddressBookUsers:(NSMutableArray *)array{
    [users addObjectsFromArray:array];
    NSMutableArray *handleIds = [[NSMutableArray alloc]init];
    for (PFObject *user in array){
        [handleIds addObject:user.objectId];
    }
    self.house[@"Members"] = array;
    [self.house saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.users.count, (self.users.count > 1) ? @"Members" : @"Member" ];
         SendNotificationAboutAddingToHouse(self.house, array, handleIds);
     }];
}


-(void)selectInvites:(NSMutableArray *)objectIds :(NSMutableArray *)names{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:self.house[@"Members"]];
    [array addObjectsFromArray:objectIds];
    [users addObjectsFromArray:names];
    self.house[@"Members"] = array;
    NSMutableArray *actualNames = [[NSMutableArray alloc]init];
    for (int i = 0; i<names.count; i++){
        [actualNames addObject:[[names objectAtIndex:i]objectForKey:@"fullname"]];
    }
    [self.house saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)array.count, (array.count > 1) ? @"Members" : @"Member" ];
         SendNotificationAboutAddingToHouse(self.house, actualNames
                                            , objectIds);
     }];
}


- (IBAction)actionPeople:(id)sender {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.frame.size.width/3 - 0.5,self.view.frame.size.width/3 - 0.5);
    layout.minimumInteritemSpacing = 0.5;
    layout.minimumLineSpacing = 0.5;
    GalleryView *gallery = [[GalleryView alloc]initWithCollectionViewLayout:layout];
    gallery.house = self.house;
    [self.navigationController pushViewController:gallery animated:YES];
}
- (IBAction)actionShowPeople:(id)sender {
    PeopleView *pv = [[PeopleView alloc]init];
    pv.usersCurrent = users;
    //pv.requesters = requestUsers;
    pv.group = self.house;
    [self.navigationController pushViewController:pv animated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0)
        {
            PresentMultiCamera(self, YES);
        }
        if (buttonIndex == 1)
        {
            PresentPhotoLibrary(self,YES);
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if (cameraOrPicture){
        UIImage *picture = ResizeImage(image, 130, 130);
        self.houseImage.image = image;
        //---------------------------------------------------------------------------------------------------------------------------------------------
        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        self.house[@"Picture"] = filePicture;
    } else {
        UIImage *picture = ResizeImage(image, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
        self.backgroundView.image = picture;
        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        self.house[@"Background"] = filePicture;
    }
    
    [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionCamera:(UITapGestureRecognizer*)sender{
    if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]){
        if (sender.view.tag == 0) cameraOrPicture = YES;
        else cameraOrPicture = NO;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Take photo", @"Choose from library", nil];
        [action showFromTabBar:[[self tabBarController] tabBar]];
    }
}


@end
