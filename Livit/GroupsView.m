
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"

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

@interface GroupsView()
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

@end


@implementation GroupsView
@synthesize users;
- (IBAction)leaveHouse:(id)sender {
    [self.house[@"Members"] removeObject:[PFUser currentUser]];
    [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (void)viewDidLoad

{
	[super viewDidLoad];
    self.title = [self.house objectForKey:@"Name"];
    self.tableView.tableHeaderView = self.headerView;
  [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
	self.refreshControl = [[UIRefreshControl alloc] init];
	events = [[NSMutableArray alloc] init];
    [self loadEvents];
    self.numberLabel.text = [[NSString stringWithFormat:@"%li",users.count] stringByAppendingString:@" members"];
    self.textView.text = [self.house objectForKey:@"Motto"];
    self.nameLabel.text = [self.house objectForKey:@"Name"];
    [self.houseImage setFile:[self.house objectForKey:@"Picture"]];
    [self.houseImage loadInBackground];
    NSArray *array = [self.house objectForKey:@"thumbnailFiles"];
    NSString *string = [NSString stringWithFormat:@"%li",array.count];
    self.labelMotto.text = [string stringByAppendingString:@" elements"];
}

-(void)loadEvents{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Houses" equalTo:self.house.objectId];
    [query whereKey:@"timeInterval" greaterThan:@([[NSDate date] timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval: -1209600.0]])];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (!error){
            [events addObjectsFromArray:objects];
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
    if (section == 1) return events.count;
    if (section == 0) return 1;
    if (section == 2){
	return [users count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section == 2){
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    [cell bindData:@"non":users[indexPath.row]:users];
    return cell;
    } else if (indexPath.section == 0) return self.cellMotto;
    else {
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.group = [events objectAtIndex:indexPath.row];
        
        return cell;
    }
        
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==2) return 70;
    if (indexPath.section ==1) return 76;
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

@end
