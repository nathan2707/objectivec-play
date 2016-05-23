//
//  CreateHouseController.m
//  Livit
//
//  Created by Nathan on 12/12/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "CreateHouseController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "push.h"
#import "image.h"
#import "camera.h"
#import "common.h"
#import "ProgressHud.h"
#import "FriendsController.h"
#import "UserCell.h"
#import "AppConstant.h"
#import "AddressBookView.h"

@interface CreateHouseController () <FacebookFriendsDelegate, UITextViewDelegate, AddressBookDelegate>

@property (nonatomic,assign) NSInteger members;
@property (strong, nonatomic) IBOutlet PFImageView *houseImage;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMotto;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellFriends;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDecision;

@property (strong, nonatomic) IBOutlet UITextView *mottoTextview;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UISwitch *switchPrivacy;
@property (strong, nonatomic) IBOutlet UITextView *nameTextView;


@end

@implementation CreateHouseController
NSMutableArray *users;
NSMutableArray *usersForTView;
PFFile *filePicture;
PFFile *fileThumbnail;

-(void)didSelectAddressBookUsers:(NSMutableArray *)array{
    usersForTView = [[NSMutableArray alloc] initWithArray:array];
    users = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser].objectId, nil];
    NSMutableArray *handleIds = [[NSMutableArray alloc]init];
    for (PFObject *user in array){
        [handleIds addObject:user.objectId];
    }
    [users addObjectsFromArray:handleIds];
    [self.tableView  reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    self.tableView.tableHeaderView = self.headerView;
    self.headerView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    self.mottoTextview.delegate = self;
    self.nameTextView.delegate = self;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            BOOL check = NO;
            NSLog(@"%@",textView.superview.superview);
            if ((textView.superview.superview == self.cellMotto) && (cell == self.cellMotto)) {
                check = YES;
            } else if ((textView.superview.superview == self.cellName) && (cell == self.cellName)){
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
            self.headerView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
            
            
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
    
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
            bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            cell.backgroundView = bgView;
            
        }
        
    }
    
    if (([textView.text isEqualToString:@""]) && (textView == self.mottoTextview)) textView.text = @"What is your motto?";
    if (([textView.text isEqualToString:@""]) && (textView == self.nameTextView)) textView.text = @"Name...";
    [textView resignFirstResponder];
    
}


-(void) selectInvites:(NSMutableArray*)objectIds :(NSMutableArray*)selection{
    NSLog(@"%li %li", objectIds.count, selection.count);
    usersForTView = [[NSMutableArray alloc] initWithArray:selection];
    users = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser].objectId, nil];
    [users addObjectsFromArray:objectIds];
    [self.tableView  reloadData];
}

- (IBAction)actionCancel:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)actionCreate:(id)sender {
    PFUser *user = [PFUser currentUser];
    PFObject *house = [PFObject objectWithClassName:@"Houses"];
    house[@"Motto"] = self.mottoTextview.text;
    house[@"Name"] = self.nameTextView.text;
    house[@"Picture"] = filePicture;
    house[@"Thumbnail"] = fileThumbnail;
    house[@"Members"] = users;
    if (self.switchPrivacy.isOn){
    house[@"Privacy"] = @"yes";
    } else {
    house[@"Privacy"] = @"no";
    }
    

            NSDictionary *data = @{
                                   @"badge" : @"Increment",
                                   @"info" : @"GroupsView",
                                   @"alert":[NSString stringWithFormat:@"%@ created %@ and added %lu people to the house.",user[PF_USER_FULLNAME],house[@"Name"],(unsigned long)users.count]
                                   };
            PFPush *push = [[PFPush alloc] init];
            NSLog(@"%@",house.objectId);
            [push setChannel:[@"h" stringByAppendingString:house[@"Name"]]];
            [push setData:data];
            [push sendPushInBackground];
           

    
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue] longitude:[[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue]];
    house[@"Geopoint"] = point;
    [house saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil){
                  [ProgressHUD showError:@"Network error."];
              }else {
                  [self.navigationController popViewControllerAnimated:YES];
              }
          }];
    
}

- (IBAction)actionPhoto:(id)sender {
    PresentPhotoLibrary(self, YES);
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    UIImage *picture = ResizeImage(image, 280, 280);
    UIImage *thumbnail = ResizeImage(image, 60, 60);
    self.houseImage.image = picture;
    
    filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
    
    fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
    return 3;
    }else if (section == 1){
        return usersForTView.count + 1;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) && (indexPath.row == 0)) return self.cellName;
    if ((indexPath.section == 0) && (indexPath.row == 1)) return self.cellMotto;
    if ((indexPath.section == 0) && (indexPath.row == 2)) return self.cellPrivacy;
    if (indexPath.section == 1){
        if (indexPath.row == 0) return self.cellFriends;
        else {
            UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
             NSLog(@"%li %li", usersForTView.count, indexPath.row);
            [cell bindData:@"non":usersForTView[indexPath.row - 1]:usersForTView];
            return cell;
        }
    
    }
    
    
    if (indexPath.section == 2) return self.cellDecision;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == 1) && (indexPath.row == 0)){
        PFUser *user = [PFUser currentUser];
        if (user[@"PicURL"] != nil){
        FriendsController *fc = [[FriendsController alloc]init];
        fc.delegate = self;
        [self.navigationController pushViewController:fc animated:YES];
        } else {
            AddressBookView *abv = [[AddressBookView alloc]init];
            abv.delegate = self;
            abv.needsToPushBack = YES;
            abv.needsToPushForth = NO;
            [self.navigationController pushViewController:abv animated:YES];
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1) && (indexPath.row != 0)) return 80;
    if ((indexPath.section == 0) && (indexPath.row == 1)) return 60;
    else return 50;
}


@end
