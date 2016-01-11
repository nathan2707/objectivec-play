//
//  ImageController.m
//  Livit
//
//  Created by Nathan on 12/25/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "ImageController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "EventCell.h"
@interface ImageController () <EventCellDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellDescription;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;

@property (strong, nonatomic) IBOutlet PFImageView *imageView;

@end

@implementation ImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    self.imageView.image = self.image;
    self.title = @"Preparation";
    self.shareLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(share)];
    [self.shareLabel addGestureRecognizer:pan];
}

-(void)share{
    NSString *string;
    if (self.array.count) {
    string = [[self.array objectAtIndex:0] objectForKey:@"Name"];
    } else {
    string = @"";
    }
    string = [string stringByAppendingString:[NSString stringWithFormat:@" - %@",self.descriptionTextView.text]];
    [self.delegate actionShare:string];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.array.count != 0){
    return 2;
    } else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else return self.array.count;
    }

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return @"Add Caption";
    else return @"Add Event";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return self.cellDescription;
    else {
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.number = @"Only";
        cell.delegate = self;
        cell.group = [self.array objectAtIndex:indexPath.row];
        return cell;
    }
    
}

-(void) actionAccept:(PFObject *)group_{
    [self.array removeAllObjects];
    [self.tableView reloadData];
    
}





@end
