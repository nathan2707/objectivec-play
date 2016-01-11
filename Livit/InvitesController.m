//
//  InvitesController.m
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "InvitesController.h"
#import "EventCell.h"
#import <Parse/Parse.h>
#import "GroupSettingsView.h"
#import "GroupsView.h"

@interface InvitesController () <EventCellDelegate>

@end

@implementation InvitesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.title = @"Invites";
    NSLog(@"%lu",self.groups.count);
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)  return @"Events";
    
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.groups.count;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
    NSInteger connection = 0;
    NSMutableArray *presentFriends = [[NSMutableArray alloc]init];
    NSMutableArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbfriends"];
    for (PFObject *group in self.groups){
        for (NSString *identity in friends){
            if ( [[group objectForKey:@"Identities"] containsObject:identity]){
                connection = connection + 1;
                [presentFriends addObject:identity];
            }
        }
    }
    
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    cell.number = [NSString stringWithFormat:@"%li",(long)connection ];
    cell.delegate = self;
    cell.group = [self.groups objectAtIndex:indexPath.row];
    return cell;
        
    }
    return nil;
}

-(void)actionDeny:(PFObject *)group_{
    NSMutableArray *array2 = [[NSMutableArray alloc]initWithArray:group_[@"Invites"]];
    [array2 removeObject:[PFUser currentUser].objectId];
    group_[@"Invites"] = array2;
    [group_ saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded){
            [self.groups removeObject:group_];
            [self.tableView reloadData];
        }
    }];
}

-(void)actionAccept:(PFObject *)group_{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:group_[@"Identities"]];
    [array addObject:[PFUser currentUser].objectId];
    group_[@"Identities"] = array;
    NSMutableArray *array2 = [[NSMutableArray alloc]initWithArray:group_[@"Invites"]];
    [array2 removeObject:[PFUser currentUser].objectId];
    group_[@"Invites"] = array2;
    [group_ saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded){
            [self.groups removeObject:group_];
            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
    GroupSettingsView *detailViewController = [[GroupSettingsView alloc] initWith:[self.groups objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    }

}
@end
