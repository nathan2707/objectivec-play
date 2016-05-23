//
//  CategoryChoiceController.m
//  Livit
//
//  Created by Nathan on 12/26/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "CategoryChoiceController.h"
#import "CatCell.h"
#import <Parse/Parse.h>
#import "SearchController.h"
@interface CategoryChoiceController () 
@property (strong, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CategoryChoiceController
NSArray *cats;
PFObject *event;
int sel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"PostEvent"]];
        self.tabBarItem.title = @"Post";
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sel = 10;
    cats = [[NSArray alloc]initWithObjects:@"Sports",@"Hang Out",@"Culture",@"Food",@"Gaming",@"Travel",@"Shopping",@"Study",@"Starred" ,nil];
    self.title = @"Post";
    event = [[PFObject alloc]initWithClassName:@"Events"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0,50,35);
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    [self.tableView registerNib:[UINib nibWithNibName:@"CatCell" bundle:nil ] forCellReuseIdentifier:@"CatCell"];
}

-(void)actionNext{
    SearchController *search = [[SearchController alloc]init];
    search.event = event;
    [self.navigationController pushViewController:search animated:YES];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 9;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Choose a category";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CatCell" forIndexPath:indexPath];
    cell.label.text = [cats objectAtIndex:indexPath.row];
    cell.logoView.image = [UIImage imageNamed:[cats objectAtIndex:indexPath.row]];
    
    if (indexPath.row == sel){
      cell.selectedView.image = [UIImage imageNamed:@"OK-32"];
      cell.userInteractionEnabled = NO;
    } else {
      cell.selectedView.image = [UIImage imageNamed:@"Full Moon Filled-32"];
      cell.userInteractionEnabled = YES;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    event[@"Category"] = [cats objectAtIndex:indexPath.row];
    sel = indexPath.row;
    [self.tableView reloadData];
}

@end
