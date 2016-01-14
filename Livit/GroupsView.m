
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"
#import "ACPButton.h"
#import "AppConstant.h"
#import "common.h"
#import "group.h"
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

@interface GroupsView()<CellDelegate, FacebookFriendsDelegate>
{
    NSMutableArray *events;
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

@end


@implementation GroupsView
@synthesize users;
NSMutableArray *requestUsers;
BOOL onefinished;
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
	events = [[NSMutableArray alloc] init];
    [self loadEvents];
    self.numberLabel.text = [NSString stringWithFormat:@"%li",users.count];
    self.textView.text = [self.house objectForKey:@"Motto"];
    self.nameLabel.text = [self.house objectForKey:@"Name"];
    [self.houseImage setFile:[self.house objectForKey:@"Picture"]];
    [self.houseImage loadInBackground];
    NSArray *array = [self.house objectForKey:@"thumbnailFiles"];
    NSString *string = [NSString stringWithFormat:@"%li",array.count];
    self.labelMotto.text = [string stringByAppendingString:@" elements"];
    self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)events.count];
    
    if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]){
        requestUsers = [[NSMutableArray alloc]init];
        [self loadRequestUsers];
        
        [self.leaveHouseButton setTitle:@"Join" forState:UIControlStateNormal];
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
    
    if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]==0){
        
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
        }
        [self.tableView reloadData];
    }];
    }
}


-(void)loadEvents{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Houses" equalTo:self.house.objectId];
    [query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
            self.numberEventsLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)events.count ];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)viewDidAppear:(BOOL)animated

{
	[super viewDidAppear:animated];

	if ([PFUser currentUser] != nil)
	{
		
	}
	else LoginUser(self);
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    if (tableView == self.requestTableView) return 1;
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Gallery";
    else if (section == 1) return @"Recent events";
    else return @"Members";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (tableView == self.requestTableView) return requestUsers.count;
    if (section == 1) return events.count;
    if (section == 0) return 1;
    if (section == 2){
	return [users count];
    }
    return 0;
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
    
    
    if (indexPath.section == 2){
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    [cell bindData:@"non":users[indexPath.row]:users];
    return cell;
    } else if (indexPath.section == 0) return self.cellMotto;
    else {
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.group = [events objectAtIndex:indexPath.row];
        
        [cell.button1 setHidden:YES];
        cell.button1.enabled = NO;
        [cell.button2 setHidden:YES];
        cell.button2.enabled = NO;
        
        myButton *joinButton = [[myButton alloc]initWithFrame:CGRectMake(325, 20, 75, 20)];
        [joinButton addTarget:self action:@selector(actionJoin:) forControlEvents:UIControlEventTouchUpInside];
        joinButton.tag = indexPath.row;
        joinButton.titleLabel.font = [UIFont systemFontOfSize: 13];
        
        if ([[cell.group objectForKey:@"Identities"] containsObject:[PFUser currentUser].objectId]){
            [joinButton setTitle:@"Going" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [joinButton setBackgroundColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1]];
            joinButton.layer.cornerRadius = 3;
            [[joinButton layer] setBorderWidth:0.5f];
            [[joinButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
            joinButton.userId = @"leave";
        } else if ([[cell.group objectForKey:@"Requests"] containsObject:[PFUser currentUser].objectId]) {
            [joinButton setTitle:@"Requested" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [joinButton setBackgroundColor:[UIColor lightGrayColor]];
            joinButton.layer.cornerRadius = 3;
            [[joinButton layer] setBorderWidth:0.5f];
            [[joinButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            joinButton.userId = @"cancel request";
        } else {
            [joinButton setTitle:@"Join" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
            [joinButton setBackgroundColor:[UIColor whiteColor]];
            joinButton.layer.cornerRadius = 3;
            [[joinButton layer] setBorderWidth:0.5f];
            [[joinButton layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
            joinButton.userId = @"join";
        }
        
        [cell addSubview:joinButton];
        
        return cell;
    }
    }
}

-(void)actionJoin:(myButton*)sender{
    PFObject *event = [events objectAtIndex:sender.tag];
    if ([sender.userId isEqualToString:@"leave"]){
        
        [sender setTitle:@"Join" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor whiteColor]];
        sender.layer.cornerRadius = 3;
        [[sender layer] setBorderWidth:0.5f];
        [[sender layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        sender.userId = @"join";
        
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Identities"]];
        [handle removeObject:[PFUser currentUser].objectId];
        event[@"Identities"] = handle;
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                 NSLog(@"error");
            }
        }];
        
    } else if ([sender.userId isEqualToString:@"cancel request"]){
        
        [sender setTitle:@"Join" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor whiteColor]];
        sender.layer.cornerRadius = 3;
        [[sender layer] setBorderWidth:0.5f];
        [[sender layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        sender.userId = @"join";
        
        NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
        [handle removeObject:[PFUser currentUser].objectId];
        event[@"Requests"] = handle;
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error){
                NSLog(@"error");
            }
        }];
        
    } else {
        
        if ([[self.house objectForKey:@"Members"] containsObject:[PFUser currentUser].objectId]){
            
        [sender setTitle:@"Going" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1]];
        sender.layer.cornerRadius = 3;
        [[sender layer] setBorderWidth:0.5f];
        [[sender layer] setBorderColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1].CGColor];
        sender.userId = @"leave";
            
            NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Identities"]];
            [handle addObject:[PFUser currentUser].objectId];
            event[@"Identities"] = handle;
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error){
                    NSLog(@"error");
                }
            }];
            
        } else {
            [sender setTitle:@"Requested" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [sender setBackgroundColor:[UIColor lightGrayColor]];
            sender.layer.cornerRadius = 3;
            [[sender layer] setBorderWidth:0.5f];
            [[sender layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            sender.userId = @"cancel request";
            
            NSMutableArray *handle = [[NSMutableArray alloc]initWithArray:event[@"Requests"]];
            [handle addObject:[PFUser currentUser].objectId];
            event[@"Requests"] = handle;
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error){
                    NSLog(@"error");
                }
            }];
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==2) return 70;
    if (indexPath.section ==1) return 60;
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section ==1){
        GroupSettingsView *gsv = [[GroupSettingsView alloc]initWith:[events objectAtIndex:indexPath.row]];
        gsv.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gsv animated:YES];
    } else if (indexPath.section ==0){
        GalleryView *gallery = [[GalleryView alloc]init];
        gallery.house = self.house;
        [self.navigationController pushViewController:gallery animated:YES];
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
         self.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.users.count ];
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
        FriendsController *facebookFriendsView = [[FriendsController alloc] init];
        facebookFriendsView.delegate = self;
        [self.navigationController pushViewController:facebookFriendsView animated:YES];
    }

}


-(void)selectInvites:(NSMutableArray *)objectIds :(NSMutableArray *)names{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:self.house[@"Members"]];
    [array addObjectsFromArray:objectIds];
    [users addObjectsFromArray:names];
    self.house[@"Members"] = array;
    [self.house saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView reloadData];
         self.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.users.count ];
     }];
}



@end
