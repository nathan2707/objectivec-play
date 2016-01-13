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
@interface CreateHouseController () <FacebookFriendsDelegate>

@property (nonatomic,assign) NSInteger members;
@property (strong, nonatomic) IBOutlet PFImageView *houseImage;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMotto;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellFriends;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDecision;

@property (strong, nonatomic) IBOutlet UITextView *mottoTextview;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UISwitch *switchPrivacy;


@end

@implementation CreateHouseController
NSMutableArray *users;
NSMutableArray *usersForTView;
PFFile *filePicture;
PFFile *fileThumbnail;

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    self.tableView.tableHeaderView = self.headerView;
    
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
    PFObject *house = [PFObject objectWithClassName:@"Houses"];
    house[@"Motto"] = self.mottoTextview.text;
    house[@"Name"] = self.nameField.text;
    house[@"Picture"] = filePicture;
    house[@"Thumbnail"] = fileThumbnail;
    house[@"Members"] = users;
    if (self.switchPrivacy.isOn){
    house[@"Privacy"] = @"yes";
    } else {
    house[@"Privacy"] = @"no";
    }
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
        FriendsController *fc = [[FriendsController alloc]init];
        fc.delegate = self;
        [self.navigationController pushViewController:fc animated:YES];
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1) && (indexPath.row != 0)) return 80;
    if ((indexPath.section == 0) && (indexPath.row == 1)) return 60;
    else return 50;
}


@end
