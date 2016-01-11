//
//  FinishController.m
//  Livit
//
//  Created by Nathan on 12/27/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "FinishController.h"
#import "ProgressHUD.h"
#import "recent.h"
@interface FinishController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UIImageView *imageEvent;
@property (strong, nonatomic) IBOutlet UITextView *nameTextView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellCaption;
@property (strong, nonatomic) IBOutlet UITextView *captionTextView;

@property (strong, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UITableViewCell *privacyCell1;
@property (strong, nonatomic) IBOutlet UISwitch *friendsSwitch;

@property (strong, nonatomic) IBOutlet UITableViewCell *privacyCell2;
@property (strong, nonatomic) IBOutlet UISwitch *publicSwitch;

@end

@implementation FinishController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Final details";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(actionShare) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"Right-32"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0,35,25);
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    NSLog(@"%@",self.event);
    self.imageEvent.image =  [UIImage imageNamed:[self.event objectForKey:@"Category"]];
    [self.datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventEditingDidEnd];
    [self.datePicker sizeToFit];
}

-(void)actionShare{
    self.event[@"Date"] = self.datePicker.date;
    PFUser *user = [PFUser currentUser];
    self.event[@"Creator"] = user.objectId;
    if ([self.friendsSwitch isOn]){
        self.event[@"Facebook"] = @(YES);
    } else {
        self.event[@"Facebook"] = @(NO);
    }
    self.event[@"timeInterval"] = @([self.datePicker.date timeIntervalSince1970]);
    if ([self.publicSwitch isOn]){
        self.event[@"Public"] = @(YES);
    } else {
        self.event[@"Public"] = @(NO);
    }
    self.event[@"Identities"] = [[NSMutableArray alloc]initWithObjects:user.objectId, nil];
    self.event[@"Name"] = self.nameTextView.text;
    self.event[@"Description"] = self.captionTextView.text;
    
    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded){
            [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ uploaded!", self.event[@"Name"]]];
            [self.navigationController popToRootViewControllerAnimated:YES];
            CreateRecentItem(user, self.event.objectId, [NSArray arrayWithObject:user],self.event[@"Name"],self.event[@"Category"]);
             }
        else [ProgressHUD showError:[NSString stringWithFormat:@"Could not upload event. Check internet connection."]];

    }];
}



-(void)dateChanged{
    self.event[@"Date"] = self.datePicker.date;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    if (textView == self.captionTextView){
    self.event[@"Description"] = textView.text;
    } else self.event[@"Name"] = textView.text;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 2;
    if (section == 1) return 1;
    if (section == 2) return 2;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == 0) && (indexPath.row == 0)) return self.cellName;
    if ((indexPath.section == 0) && (indexPath.row == 1)) return self.cellCaption;
    if ((indexPath.section == 1) && (indexPath.row == 0)) return self.dateCell;
    if ((indexPath.section == 2) && (indexPath.row == 0)) return self.privacyCell1;
    if ((indexPath.section == 2) && (indexPath.row == 1)) return self.privacyCell2;
    else return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return @"Info";
    if (section == 1) return @"Starting Date";
    if (section == 2) return @"Disclosure";
    return @"";

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 100;
    } else return 50;
}
@end
