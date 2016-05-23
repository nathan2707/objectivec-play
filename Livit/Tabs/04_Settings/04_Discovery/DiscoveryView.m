//
//  DiscoveryView.m
//  attempt
//
//  Created by Nathan on 7/8/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import "DiscoveryView.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ProgressHUD.h"
#import "CatCell.h"

@interface DiscoveryView ()


@property (strong, nonatomic) IBOutlet UITableViewCell *cellAge;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellShow;
@property (strong, nonatomic) IBOutlet UISwitch *switchMen;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellShowWomen;
@property (strong, nonatomic) IBOutlet UISwitch *switchWomen;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellRadius;
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UISlider *radiusSlider;
@property (strong, nonatomic) IBOutlet UILabel *radiusLabel;


@end

@implementation DiscoveryView
@synthesize cellAge, cellRadius, cellShow, cellShowWomen;
NSArray *cats;
NSMutableArray *selection;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Preferences";
    cats = [[NSArray alloc]initWithObjects:@"Sports",@"Hang out",@"Culture",@"Food",@"Gaming",@"Travel",@"Shopping",@"Study",@"Starred" ,nil];
  
    NSString *object1 = [[NSUserDefaults standardUserDefaults]valueForKey:@"Category1"];
    if (object1 == NULL){
        object1 = @"Sports";
    }
    NSString *object2 = [[NSUserDefaults standardUserDefaults]valueForKey:@"Category2"];
    if (object2 == NULL){
        object2 = @"Hang out";
    }
    NSString *object3 = [[NSUserDefaults standardUserDefaults]valueForKey:@"Category3"];
    if (object3 == NULL){
        object3 = @"Culture";
    }
    selection = [[NSMutableArray alloc]initWithObjects:@([cats indexOfObject:object1]),@([cats indexOfObject:object2]),@([cats indexOfObject:object3]), nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"CatCell" bundle:nil ] forCellReuseIdentifier:@"CatCell"];
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"ageMax"];
    self.radiusSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"radiusMax"];
    self.switchMen.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"men"];
    self.switchWomen.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"women"];
    self.cellRadius.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellAge.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.radiusSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.switchMen addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.switchWomen addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.radiusLabel.text = [NSString stringWithFormat:@"%i mi", (int)self.radiusSlider.value];
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    NSArray *categories;
    if (selection.count == 0){
    categories = [[NSArray alloc]initWithObjects:[cats objectAtIndex:0],[cats objectAtIndex:1],[cats objectAtIndex:2],nil];
    }else if (selection.count == 1){
    categories = [[NSArray alloc]initWithObjects:[cats objectAtIndex:[[selection objectAtIndex:0]intValue]],[cats objectAtIndex:0],[cats objectAtIndex:1],nil];
    } else if (selection.count == 1){
    categories = [[NSArray alloc]initWithObjects:[cats objectAtIndex:[[selection objectAtIndex:0]intValue]],[cats objectAtIndex:[[selection objectAtIndex:1]intValue]],[cats objectAtIndex:2],nil];
    } else {
        NSLog(@"%i",[[selection objectAtIndex:0]intValue]);
    categories = [[NSArray alloc]initWithObjects:[cats objectAtIndex:[[selection objectAtIndex:0]intValue]],[cats objectAtIndex:[[selection objectAtIndex:1]intValue]],[cats objectAtIndex:[[selection objectAtIndex:2]intValue]],nil];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[categories objectAtIndex:0] forKey:@"Category1"];
    [[NSUserDefaults standardUserDefaults]setObject:[categories objectAtIndex:1] forKey:@"Category2"];
    [[NSUserDefaults standardUserDefaults]setObject:[categories objectAtIndex:2] forKey:@"Category3"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 2;
    }
    else return 9;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return @"finder settings";
    else return @"activity preferences";
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        if (indexPath.row == 0) return cellAge;
        if (indexPath.row == 1) return cellRadius;
        if (indexPath.row == 2) return cellShowWomen;
        if (indexPath.row == 3) return cellRadius;
    } else if (indexPath.section == 1){
        CatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CatCell" forIndexPath:indexPath];
        cell.label.text = [cats objectAtIndex:indexPath.row];
        cell.logoView.image = [UIImage imageNamed:[cats objectAtIndex:indexPath.row]];
        
        if ([selection containsObject:@(indexPath.row)]){
            cell.selectedView.image = [UIImage imageNamed:@"OK-32"];
            cell.userInteractionEnabled = NO;
        } else {
            cell.selectedView.image = [UIImage imageNamed:@"Full Moon Filled-32"];
            cell.userInteractionEnabled = YES;
        }
        return cell;
    }
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        if (selection.count >= 3){
            [selection removeObject:[selection firstObject]];
        }
        [selection addObject:@(indexPath.row)];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}


#pragma mark - Helper
- (void)valueChanged:(id)sender {
    
    if (sender == self.ageSlider) {
        [[NSUserDefaults standardUserDefaults] setInteger: (int)self.ageSlider.value forKey:@"ageMax"];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    } else if (sender == self.switchMen) {
        [[NSUserDefaults standardUserDefaults] setBool:self.switchMen.isOn forKey:@"men"];
    } else if (sender == self.switchWomen) {
        [[NSUserDefaults standardUserDefaults] setBool:self.switchWomen.isOn forKey:@"women"];
    } else if (sender == self.radiusSlider) {
        self.radiusLabel.text = [NSString stringWithFormat:@"%i mi", (int)self.radiusSlider.value];
        [[NSUserDefaults standardUserDefaults] setInteger: (int)self.radiusSlider.value forKey:@"radiusMax"];
    }
    PFUser *user = [PFUser currentUser];
    user[PF_USER_RADIUS] = @(self.radiusSlider.value);
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
