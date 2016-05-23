//
//  GroupSettingsView.m
//  Livit
//
//  Created by Nathan on 10/14/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"
#import "CommentCell.h"
#import "AppConstant.h"
#import "recent.h"
#import "common.h"
#import "GroupSettingsView.h"
#import "ChatView.h"
#import "UserCell.h"
#import "ProfileView.h"
#import "camera.h"
#import "FriendsController.h"
#import "image.h"
#import "push.h"
#import "DAKeyboardControl.h"
#import "KPTimePicker.h"
#import "Categories.h"
#import <MapKit/MapKit.h>
#import "PeopleView.h"
#import "GalleryView.h"
#import "ImageController.h"
#import "SearchController.h"
#import "myTap.h"
#import "AddressBookView.h"

// Make a notification (not push, just on the app, just like a message was received, when a request is received.

@interface GroupSettingsView() <CellDelegate, CellDelegate2 ,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate,UIPopoverControllerDelegate, KPTimePickerDelegate, MKMapViewDelegate, FacebookFriendsDelegate, ImageDelegate, UITextViewDelegate, SearchLocationDelegate, AddressBookDelegate>
{
    PFObject *group;
    NSMutableArray *users;
    NSMutableArray *usersRequest;
    NSMutableArray *pfusersRequest;
    NSMutableArray *commenters;
    NSMutableArray *invited;
    NSMutableArray *fileBank;
    NSMutableArray *filePictureBank;
    NSMutableArray *captions;
    NSMutableArray *annotations;
    double spanlat;
    double spanlong;
    BOOL oneFinished;
    BOOL galleryOrMain;
    BOOL pickerCalled;
    BOOL cameraOrKeyboard;
    BOOL description;
}
@property (strong, nonatomic) IBOutlet UITableView *requestTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellGallery;
@property (strong, nonatomic) IBOutlet UILabel *labelGallery;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEditTime;
@property (strong, nonatomic) IBOutlet UIDatePicker *picker;

@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;

@property (strong, nonatomic) IBOutlet UILabel *numberRequestsLabel;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;

@property (strong, nonatomic) IBOutlet UIButton *leaveButton;
@property (nonatomic, strong) NSMutableArray *sampleDataArray;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDescription;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextview;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *eventImage;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;

@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellDetails;
@property (strong, nonatomic) IBOutlet UILabel *labelDay;
@property (strong, nonatomic) IBOutlet UILabel *labelMonth;
@property (strong, nonatomic) IBOutlet UILabel *labelHour;

@property (strong, nonatomic) IBOutlet UILabel *labelAffluence;

@property (strong, nonatomic) IBOutlet UIView *timeView;
@property(strong,nonatomic) KPTimePicker *timePicker;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *invitesCountLabel;

@end


@implementation GroupSettingsView


@synthesize cellName;
@synthesize labelName;
@synthesize eventImage;
@synthesize eventLabel;
@synthesize viewHeader;

- (IBAction)tapGallery:(id)sender {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.frame.size.width/3 - 0.5,self.view.frame.size.width/3 - 0.5);
    layout.minimumInteritemSpacing = 0.5;
    layout.minimumLineSpacing = 0.5;
    GalleryView *gallery = [[GalleryView alloc]initWithCollectionViewLayout:layout];
    gallery.house = group;
    [self.navigationController pushViewController:gallery animated:YES];
    
}

-(void)sendNotif:(NSString *)message{
    NSDictionary *data = @{
                           @"badge" : @"Increment",
                           @"info" : @"GroupSettingsView",
                           @"alert": message
                           };
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[@"h" stringByAppendingString:group.objectId]];
        [push setData:data];
        [push sendPushInBackground];
}

-(void)didSelectAddressBookUsers:(NSMutableArray *)array{
    NSMutableArray *handleIds = [[NSMutableArray alloc]init];
    for (PFObject *user in array){
        [handleIds addObject:user.objectId];
    }
    [invited addObjectsFromArray:handleIds];
    [group[@"Invites"] addObjectsFromArray:handleIds];
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         SendNotificationAboutInvitingToEvent(group, [array valueForKey:PF_USER_FULLNAME], handleIds);
         [self.tableView  reloadData];
     }];
    
}


-(void)selectInvites:(NSMutableArray *)objectIds :(NSMutableArray *)names{
    [group[@"Invites"] addObjectsFromArray:objectIds];
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         SendNotificationAboutInvitingToEvent(group, [names valueForKey:PF_USER_FULLNAME], objectIds);
     }];
}

-(void)loadInvites{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" containedIn:group[@"Invites"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == 0){
            [invited addObjectsFromArray:objects];
        }
    }];
}

- (IBAction)inviteFriends:(id)sender {
    if ([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]){
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

- (id)initWith:(PFObject *)group_
{
    self = [super init];
    group = group_;
    return self;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.textView.text = @"";
    self.textView.textColor = [UIColor blackColor];
    return YES;
}
- (void)actionChat {
    if ([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]){
        ChatView *chatView = [[ChatView alloc] initWith:self.recent[PF_RECENT_GROUPID]];
        chatView.event = group;
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }
}

-(void)changeInformation {
    NSArray *array = group[@"Identities"];
    self.labelAffluence.text = [NSString stringWithFormat:@"%lu",(unsigned long)array.count];
    NSArray *array2 = group[@"Requests"];
    self.numberRequestsLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)array2.count];
    NSDate *date = group[@"Date"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM"];
    self.labelMonth.text = [df stringFromDate:date];
    NSLog(@"value class = %@", [self.labelMonth.text class]);
    [df setDateFormat:@"hh:mm aa"];
    self.labelHour.text = [df stringFromDate:date];
    
    [df setDateFormat:@"d"];
    self.labelDay.text = [df stringFromDate:date];
    
    if ([group[@"Description"]isEqualToString:@""]){
        description = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        self.descriptionTextview.text = group[@"Description"];
    }
    
}

-(void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date{
    [self show:NO timePickerAnimated:YES];
    if (date){
        group[@"Date"] = date;
        [self changeInformation];
        [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
             } else {
                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
                 [df setDateFormat:@"MMMM"];
                 NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
                 [df2 setDateFormat:@"eeee d"];
                 PFUser *user = [PFUser currentUser];
                 [self sendNotif:[NSString stringWithFormat:@"%@ changed the time of %@ to %@ on %@",user[PF_USER_FULLNAME],group[@"Name"],[df stringFromDate:date],[df2 stringFromDate:date]]];
             }
             
         }];
    }
    
    self.tableView.scrollEnabled = YES;
}

-(void)show:(BOOL)show timePickerAnimated:(BOOL)animated{
    if(show){
        self.timePicker.pickingDate = [NSDate date];
        [self.view addSubview:self.timePicker];
    }
    else{
        [self.timePicker removeFromSuperview];
    }
}

-(void)callDP{
    if (pickerCalled == NO){
        pickerCalled = YES;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        pickerCalled = NO;
        group[@"Date"] = self.picker.date;
        [self loadWhen];
        group[@"timeInterval"] = @([self.picker.date timeIntervalSince1970]);
        [self changeInformation];
        [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
             [self.tableView reloadData];
         }];
        
    }
}

//-(void)makeMapView{
//    [viewHeader setFrame:CGRectMake(0, 0, 414, 240)];
//    GMSPanoramaView *panoView = [[GMSPanoramaView alloc] initWithFrame:eventImage.frame];
//    CGFloat nearestLat = floorf([[group[@"Location"] objectForKey:@"lat"] doubleValue] * 1000 + 0.5) / 1000;
//    CGFloat nearestLong = floorf([[group[@"Location"] objectForKey:@"long"] doubleValue] * 1000 + 0.5) / 1000;
//    [panoView moveNearCoordinate:CLLocationCoordinate2DMake(nearestLat,nearestLong)];
//    panoView.camera = [GMSPanoramaCamera cameraWithHeading:90
//                                                     pitch:0
//                                                      zoom:1];
//    [panoView setAllGesturesEnabled:NO];
//    [viewHeader addSubview:panoView];
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takeMainPicture)];
//    [viewHeader addGestureRecognizer:tap];
//}

-(void)loadWhen{
    NSString *timeString = @"";
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:group[@"Date"]];
    double absoluteTime = fabs(timeSince);
    
    if (absoluteTime/60 < 1) {
        timeString = [NSString stringWithFormat:@"%i seconds",(int)absoluteTime];
    }
    else if (absoluteTime/3600 < 1) {
        timeString = [NSString stringWithFormat:@"%i minutes",(int)absoluteTime/60];
    }
    else if (absoluteTime/(3600*24) < 1) {
        timeString = [NSString stringWithFormat:@"%i hours",(int)absoluteTime/3600];
    }
    else{
        timeString = [NSString stringWithFormat:@"%i days",(int)absoluteTime/(3600*24)];
    }
    if (timeSince < 0){
        self.eventLabel.text = [NSString stringWithFormat:@"In %@",timeString];
        //self.eventLabel.textColor = [UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1];
    } else {
        self.eventLabel.text = [NSString stringWithFormat:@"%@ ago",timeString];
        //self.eventLabel.textColor = [UIColor redColor];
    }
    
}

- (void)loadGroup

{
    [self loadWhen];
    [self changeInformation];
    if ([group[@"Creator"] isEqualToString:[[PFUser currentUser]objectId]]){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callDP)];
        [self.timeView addGestureRecognizer:tap];
        self.descriptionTextview.editable = YES;
        self.descriptionTextview.selectable = YES;
        
        self.descriptionTextview.userInteractionEnabled = YES;
    }
    if (([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) && ([group[@"Creator"] isEqualToString:[[PFUser currentUser] objectId]])){
        [self.leaveButton setTitle:@"Delete" forState:UIControlStateNormal];
        //[self.leaveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else if ([group[@"Requests"] containsObject:[[PFUser currentUser] objectId]]){
        [self.leaveButton setTitle:@"Requested" forState:UIControlStateNormal];
        self.leaveButton.enabled = NO;
    } else {
        [self.leaveButton setTitle:@"Join" forState:UIControlStateNormal];
        //[self.leaveButton setTitleColor:[UIColor colorWithRed:(44.f/255.f) green:(161.f/255.f) blue:(18.f/255.f) alpha:1] forState:UIControlStateNormal];
    }
    if (group[@"LocationString"]){
        [self.locationButton setTitle:group[@"LocationString"] forState:UIControlStateNormal];
    }
    
    if ( group[@"Picture"] == nil){
        //[self makeMapView];
    } else {
        [eventImage setFile:group[@"Picture"]];
        [eventImage loadInBackground];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takeMainPicture)];
        [eventImage addGestureRecognizer:tap];
    }
    fileBank = [[NSMutableArray alloc]init];
    [fileBank addObjectsFromArray:group[@"pictureFiles"]];
    
    filePictureBank = [[NSMutableArray alloc]init];
    [filePictureBank addObjectsFromArray:group[@"pictureFiles"]];
    
    captions = [[NSMutableArray alloc]init];
    [captions addObjectsFromArray:group[@"captions"]];
    
    if (![group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]){
        [self.mapView setHidden:YES];
    }
    
    [usersRequest addObjectsFromArray:group[@"Requests"]];
    if ([usersRequest count] < 1) {
        oneFinished = YES;
    }
    
    for (NSString * obj in usersRequest) {
        if ([obj isKindOfClass:[NSString class]]) {
            
            PFQuery *query = [PFUser query];
            [query getObjectInBackgroundWithId:obj block:^(PFObject *obj, NSError *error) {
                if (obj && !error) {
                    [pfusersRequest addObject:obj];
                    if ([pfusersRequest count] >= [usersRequest count]) {
                        if (oneFinished) {
                            [self.tableView reloadData];
                            
                        }
                        else{
                            oneFinished = YES;
                        }
                    }
                }
            }];
            
        }
        
    }
    
}





- (void)loadUsers

{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID containedIn:group[@"Identities"]];
    [query orderByAscending:PF_USER_FULLNAME];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [users removeAllObjects];
             [users addObjectsFromArray:objects];
             if (oneFinished) {
                 [self.tableView reloadData];
                 self.requestTableView.delegate = self;
                 [self.requestTableView reloadData];
                 self.requestTableView.frame = CGRectMake(0,0,self.view.frame.size.width, usersRequest.count * 50);
                 if ([group[@"Identities"] containsObject:[PFUser currentUser].objectId]){
                 [self.view addSubview:self.requestTableView];
                 }
                 [self updateMapWithOthers];
             }
             else{
                 oneFinished = YES;
             }
         }
         else [ProgressHUD showError:@"Network error."];
     }];
}

-(void)updateMapWithEvent{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[group[@"Location"] objectForKey:@"lat"] doubleValue], [[group[@"Location"] objectForKey:@"long"] doubleValue]) addressDictionary:group[@"LocationString"]];
    NSLog(@"%@",group[@"Location"]);
    [self addPlacemarkAnnotationToMap:placemark addressString:group[@"Name"]];
    [self recenterMapToPlacemark:placemark];
}

-(void)updateMapWithOthers{
    for (PFObject *user in users){
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue], [[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue]) addressDictionary:nil];
        [self addPlacemarkAnnotationToMap:placemark addressString:user[PF_USER_FULLNAME]];
        
        if (user.objectId == [PFUser currentUser].objectId){
            spanlong = fabs([[user[PF_USER_POSITION] objectForKey:@"long"] doubleValue] - [[group[@"Location"] objectForKey:@"long"] doubleValue]);
            spanlat  = fabs([[user[PF_USER_POSITION] objectForKey:@"lat"] doubleValue] - [[group[@"Location"] objectForKey:@"lat"] doubleValue]);
            [self recenterMapToPlacemark:placemark];
        }
        
    }
}

#pragma mark - Helpers map view

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = placemark.location.coordinate;
    annotation.title = address;
    [annotations addObject:annotation];
    
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation*)annotation
{
    if ([annotation.title isEqualToString:group[@"Name"]]) return nil;
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    if ([annotation.title isEqualToString:group[@"Name"]]== 0) {
        for (PFObject *user in users){
            if ([annotation.title isEqualToString:user[PF_USER_FULLNAME]]){
                PFImageView *pfimage = [[PFImageView alloc]initWithFrame:CGRectMake(0,0,5,5)];
                [pfimage setFile:user[PF_USER_THUMBNAIL]];
                [pfimage loadInBackground];
                UIImage *image = ResizeImage(pfimage.image, 30, 30);
                annotationView.image = image;
                annotationView.layer.cornerRadius = annotationView.frame.size.width/2;
                annotationView.layer.masksToBounds = YES;
                myTap *tap = [[myTap alloc]initWithTarget:self action:@selector(actionProfile2:)];
                tap.userId = user.objectId;
            }
        }
    }
    return annotationView;
}

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = spanlat + 0.1*spanlat;
    span.longitudeDelta = spanlong + 0.1*spanlong;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region animated:YES];
    //[self.mapView showAnnotations:annotations animated:YES];
}



- (void)commentAction{
    
    if ([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]){
        if ([commenters containsObject:[PFUser currentUser].objectId] == 0){
            
            self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                       self.view.bounds.size.height - 40.0f,
                                                                       self.view.bounds.size.width,
                                                                       40.0f)];
            UIToolbar *toolBar = self.toolBar;
            self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:self.toolBar];
            self.toolBar.backgroundColor = [UIColor whiteColor];
            
            self.toolBar.barStyle = UIBarStyleBlackOpaque;
            
            self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:self.toolBar];
            
            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(65.0f,6.0f,self.toolBar.bounds.size.width - 50.0f - 68.0f,30.0f)];
            self.textView.clipsToBounds = YES;
            self.textView.layer.cornerRadius = 5.0f;
            self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.textView setKeyboardAppearance:UIKeyboardAppearanceAlert];
            self.textView.text = @"Give advice...";
            self.textView.textColor = [UIColor lightGrayColor];
            [self.textView setDelegate:self];
            
            [self.toolBar addSubview:self.textView];
            
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
            [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sendButton addTarget:self action:@selector(shouldAcceptTextChanges) forControlEvents:UIControlEventTouchUpInside];
            
            sendButton.frame = CGRectMake(self.toolBar.bounds.size.width - 58.0f,
                                          6.0f,
                                          58.0f,
                                          29.0f);
            [self.toolBar addSubview:sendButton];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(shouldCancelTextChanges) forControlEvents:UIControlEventTouchUpInside];
            
            cancelButton.frame = CGRectMake(5.0f,
                                            6.0f,
                                            58.0f,
                                            29.0f);
            [self.toolBar addSubview:cancelButton];
            
            
            self.view.keyboardTriggerOffset = self.toolBar.bounds.size.height;
            
            CGRect rect = self.view.frame;
            [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
                /*
                 Try not to call "self" inside this block (retain cycle).
                 But if you do, make sure to remove DAKeyboardControl
                 when you are done with the view controller by calling:
                 [self.view removeKeyboardControl];
                 */
                
                CGRect toolBarFrame = toolBar.frame;
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
                toolBar.frame = toolBarFrame;
                
                CGRect tableViewFrame = rect;
                tableViewFrame.size.height = toolBarFrame.origin.y;
                
            } constraintBasedActionHandler:nil];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    self.invitesCountLabel.text = [NSString stringWithFormat:@"%lu",[group[@"Invites"] count] ];
    NSArray *array = [group objectForKey:@"pictureFiles"];
    NSString *string = [NSString stringWithFormat:@"%li",array.count];
    self.labelGallery.text = [string stringByAppendingString:@" elements"];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updateInputViewFrameWithKeyboardFrame];
}

- (void)_updateInputViewFrameWithKeyboardFrame
{
    // Calculate the height the input view ideally
    // has based on its textview's content
    UITextView *textView = self.textView;
    
    CGFloat newInputViewHeight;
    if ([NSURLSession class])
    {
        newInputViewHeight = textViewHeight(textView);
    } else {
        newInputViewHeight = self.textView.contentSize.height;
    }
    
    //10 is the border of the uitoolbar top and bottom
    newInputViewHeight += 10;
    newInputViewHeight = ceilf(newInputViewHeight);
    //newInputViewHeight = MIN(maxInputViewHeight, newInputViewHeight);
    
    // If the new input view height equals the current,
    // nothing has to be changed
    if (self.textView.bounds.size.height == newInputViewHeight) {
        return;
    }
    // If the new input view height is bigger than the view available, do nothing
    if ((self.view.bounds.size.height - self.view.keyboardFrameInView.size.height < newInputViewHeight)) {
        return;
    }
    
    CGRect inputViewFrame = self.textView.frame;
    inputViewFrame.size.height = newInputViewHeight;
    self.textView.frame = inputViewFrame;
    
    CGRect toolBarFrame = self.toolBar.frame;
    toolBarFrame.size.height = newInputViewHeight +10;
    toolBarFrame.origin.y = self.view.keyboardFrameInView.origin.y - toolBarFrame.size.height;
    self.toolBar.frame = toolBarFrame;
    
    self.view.keyboardTriggerOffset = self.toolBar.bounds.size.height;
    
    self.descriptionTextview.superview.superview.frame = CGRectMake(self.descriptionTextview.superview.superview.frame.origin.x, self.descriptionTextview.superview.superview.frame.origin.y, self.descriptionTextview.superview.superview.frame.size.width, [self measureHeightOfUITextView:self.descriptionTextview]+10);
}

static inline CGFloat textViewHeight(UITextView *textView) {
    NSTextContainer *textContainer = textView.textContainer;
    CGRect textRect =
    [textView.layoutManager usedRectForTextContainer:textContainer];
    
    CGFloat textViewHeight = textRect.size.height +
    textView.textContainerInset.top + textView.textContainerInset.bottom;
    
    return textViewHeight;
}

-(void)actionProfile:(PFUser *)user {
    ProfileView *profileView = [[ProfileView alloc] initWith:user.objectId];
    [self.navigationController pushViewController:profileView animated:YES];
}

-(void)actionProfile2:(myTap*)sender{
    ProfileView *profileView = [[ProfileView alloc] initWith:sender.userId];
    [self.navigationController pushViewController:profileView animated:YES];
}


-(void)showBackView{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[GMSServices provideAPIKey:@"AIzaSyCMdkKlurqOvobVq2GHf5iXmTi4eliXVac"];
    pickerCalled = NO;
    
    spanlong = 0.008;
    spanlat = 0.008;
    
    UIButton *boutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [boutton addTarget:self action:@selector(actionReport) forControlEvents:UIControlEventTouchUpInside];
    boutton.frame = CGRectMake(0,0,25,25);
    [boutton setImage:[UIImage imageNamed:@"flag32"] forState:UIControlStateNormal];
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithCustomView:boutton];
    self.navigationItem.rightBarButtonItems = [NSMutableArray arrayWithObjects:flipButton, nil];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showBackView)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    if ([[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count- 2].title isEqualToString: @"Events"]){
        //UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(actionWrite)];
        //[barButton setTintColor:[UIColor whiteColor]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionWrite) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0,0,35,35);
        [button setImage:[UIImage imageNamed:@"bubbly"] forState:UIControlStateNormal];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButton,flipButton,nil];

    }
    
    if ([group[@"Identities"]containsObject:[PFUser currentUser].objectId] == 0){
        [viewHeader setFrame:CGRectMake(0, 0, self.view.frame.size.width, 212)];
    } else {
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionChat)];
        [recognizer setNumberOfTouchesRequired:1];
        [self.view setUserInteractionEnabled:YES];
        recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:recognizer];
    }
    self.descriptionTextview.delegate = self;
    self.descriptionTextview.editable = NO;
    self.descriptionTextview.selectable = NO;
    self.tableView.tableHeaderView = viewHeader;
    self.descriptionTextview.userInteractionEnabled = NO;
    description = YES;
    
    self.title = group[@"Name"];
    [self.mapView setMapType:MKMapTypeSatellite];
    annotations = [[NSMutableArray alloc]init];
    users = [[NSMutableArray alloc] init];
    usersRequest = [[NSMutableArray alloc] init];
    pfusersRequest = [[NSMutableArray alloc] init];
    commenters = [[NSMutableArray alloc] init];
    invited = [[NSMutableArray alloc] init];
    [self.requestTableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [self loadGroup];
    [self loadInvites];
    [self loadUsers];
    [self updateMapWithEvent];
    _sampleDataArray = [[NSMutableArray alloc] init];
    
    if (group[@"Comments"]) {
        _sampleDataArray = group[@"Comments"];
    }
    
    self.timePicker = [[KPTimePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-60)];
    self.timePicker.delegate = self;
    self.timePicker.minimumDate = [self.timePicker.pickingDate dateAtStartOfDay];
    self.timePicker.maximumDate = [[[self.timePicker.pickingDate dateByAddingMinutes:(60*24)] dateAtStartOfDay] dateBySubtractingMinutes:5];
    
}

#pragma mark - custom delegate for toolbar actions

-(void)shouldAcceptTextChanges{
    NSString *totalString = [NSString stringWithFormat:@"%@%@",[PFUser currentUser].objectId, self.textView.text];
    [_sampleDataArray addObject:totalString];
    group[@"Comments"] = _sampleDataArray;
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
         [self.textView resignFirstResponder];
         [self.toolBar removeFromSuperview];
         [self sendNotif:[NSString stringWithFormat:@"%@ said: %@",[PFUser currentUser][PF_USER_FULLNAME], self.textView.text]];
     }];
}

-(void)shouldCancelTextChanges{
    [self.textView resignFirstResponder];
    [self.toolBar removeFromSuperview];
}

#pragma mark - Backend actions

- (IBAction)leaveEvent:(id)sender {
    
    if (([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) && ([group[@"Creator"] isEqualToString:[[PFUser currentUser] objectId]] == NO)){
        
        NSMutableArray *identities = [[NSMutableArray alloc]initWithArray:group[@"Identities"]];
        [identities removeObject:[[PFUser currentUser]objectId]];
        group[@"Identities"] = identities;
        NSMutableArray *membs = [[NSMutableArray alloc]initWithArray:self.recent[@"Members"]];
        [membs removeObject:[PFUser currentUser]];
        self.recent[@"Members"] = membs;
        group[@"Users"] = membs;
        group[@"Recent"] = self.recent;
        [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
             } else {
                 SendNotificationAboutLeaving(group, @"event");
                  [self.navigationController popToRootViewControllerAnimated:YES];
             }
         }];
        
    } else if (([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) && ([group[@"Creator"] isEqualToString:[[PFUser currentUser] objectId]])){
        
        PFUser *user = [PFUser currentUser];
        [self sendNotif:[NSString stringWithFormat:@"%@ cancelled %@",user[PF_USER_FULLNAME],group[@"Name"]]];
        [self.recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        [self.navigationController popToRootViewControllerAnimated:YES];

        
    } else if ([group[@"Requests"] containsObject:[[PFUser currentUser] objectId]] == 0){
        // Request to join event
        [self.leaveButton setTitle:@"Requested" forState:UIControlStateNormal];
        NSMutableArray *array2 = [[NSMutableArray alloc]initWithArray:group[@"Requests"]];
        [array2 addObject:[PFUser currentUser].objectId];
        group[@"Requests"] = array2;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil){
                 [ProgressHUD showError:@"Network error."];
                 
             } else {
                 SendNotificationAboutRequestingToJoin(group, @"event");
             }
             
         }];
        
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    if (tableView == self.requestTableView) return 1;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (tableView == self.requestTableView) return usersRequest.count;
    else {
        if (section == 1) return [group[@"Comments"] count];
        if (section == 0){
            if (pickerCalled) return 4;
            return 3;
        }
        if (section == 2) return 1;
        
        return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if (tableView != self.requestTableView){
        if (section == 1) return @"Advice";
        if (section == 0) return @"Information";
        if (section == 2) return @"Photos";
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if (tableView == self.requestTableView){
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        
        [cell instaSetUp:pfusersRequest[indexPath.row]:indexPath.row];
        cell.delegate = self;
        return cell;
        
    }
    else {
        
        
        
        if ([users count]==0) {
            UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
            return cell;
        }
        if (indexPath.section == 2) return self.cellGallery;
        if (indexPath.section == 1){
            CommentCell *cell =[tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            PFUser *foundUser = nil;
            for (PFUser *user in users) {
                if ([user.objectId isEqualToString:[[group[@"Comments"] objectAtIndex:indexPath.row] substringToIndex:10]]) {
                    foundUser = user;
                }
            }
            if (foundUser) {
                [cell bindData:[[group[@"Comments"] objectAtIndex:indexPath.row] substringFromIndex:10]:foundUser];
            }
            
            cell.delegate = self;
            return cell;
        }
        if ((indexPath.section == 0) && (indexPath.row == 0)){
            return self.locationCell;
        }
        if ((indexPath.section == 0) && (indexPath.row == 1)){
            return self.cellDetails;
        }
        if (pickerCalled){
            if ((indexPath.section == 0) && (indexPath.row == 3)){
                return self.cellDescription;
            }
            if ((indexPath.section == 0) && (indexPath.row == 2)){
                [self.picker sizeToFit];
                self.picker.date = group[@"Date"];
                return self.cellEditTime;
            }
        }else {
            if ((indexPath.section == 0) && (indexPath.row == 2)){
                return self.cellDescription;
            }
        }
    }
    return nil;
}

-(void)actionAccept:(PFUser*)user_{
    [usersRequest removeObject:user_.objectId];
    [pfusersRequest removeObject:user_];
    self.requestTableView.frame = CGRectMake(0,0,self.view.frame.size.width, usersRequest.count * 50);
    NSLog(@"%@",group[@"Requests"]);
    group[@"Requests"] = usersRequest;
    NSLog(@"%@",group[@"Requests"]);
    NSMutableArray *identities = [NSMutableArray arrayWithArray:group[@"Identities"]];
    NSString *idString = [user_ objectId];
    if ([identities containsObject:idString]){
    } else {
        [identities addObject:[user_ objectId]];
        group[@"Identities"] = identities;
        group[@"Affluence"] = @([group[@"Affluence"] integerValue]+1);
        //        if ([group[@"Affluence"]integerValue] >= [group[@"Capacity"]integerValue]) {
        //            group[@"Full"]=@"YES";
        //        }
        [users addObject:user_];
        group[@"Users"] = users;
    }
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView reloadData];
         [self.requestTableView reloadData];
         NSString *groupId = [group objectId];
         NSString *description = @"";
         for (PFUser *user in users)
         {
             NSLog(@"%@",user[PF_USER_FULLNAME]);
             if ([description length] != 0) description = [description stringByAppendingString:@" & "];
             description = [description stringByAppendingString:user[PF_USER_FULLNAME]];
         }
         for (PFUser *user in users)
         {
             CreateRecentItem(user, groupId, users, description, group[@"Category"],group);
         }
         
         SendNotificationAboutAcceptingRequest(group, user_, @"event");

     }];
}

-(void)actionDeny:(PFUser*)user_{
    [usersRequest removeObject:user_.objectId];
    [pfusersRequest removeObject:user_];
    self.requestTableView.frame = CGRectMake(0,10,self.view.frame.size.width, usersRequest.count * 50);
    NSLog(@"%@",group[@"Requests"]);
    group[@"Requests"] = usersRequest;
    NSLog(@"%@",group[@"Requests"]);
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [ProgressHUD showError:@"Network error."];
         } else {
             [self.tableView reloadData];
             [self.requestTableView reloadData];
         }
     }];
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2){
        GalleryView *gallery = [[GalleryView alloc]init];
        gallery.house = group;
        [self.navigationController pushViewController:gallery animated:YES];
    } else if (indexPath.section == 3) {
        PFObject *obj = [pfusersRequest objectAtIndex:indexPath.row];
        ProfileView *profileView = [[ProfileView alloc] initWith:obj.objectId];
        [self.navigationController pushViewController:profileView animated:YES];
    } else if ((indexPath.section == 0) && (indexPath.row == 1)){
        PeopleView *peopleView = [[PeopleView alloc]init];
        peopleView.usersCurrent = users;
        peopleView.requesters = pfusersRequest;
        peopleView.invited = invited;
        peopleView.group = group;
        [self.navigationController pushViewController:peopleView animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.requestTableView){
        
        if (indexPath.section == 1) {
            return 50;
        }
        if (indexPath.section ==0 && indexPath.row ==1) return 116;
        if (pickerCalled) {
            if (indexPath.section ==0 && indexPath.row ==2){
                return 100;
            }
            if (indexPath.section ==0 && indexPath.row ==3){
                
                return [self measureHeightOfUITextView:self.descriptionTextview]+10;
            }
        } else {
            if (indexPath.section ==0 && indexPath.row ==2){
                return [self measureHeightOfUITextView:self.descriptionTextview]+10;
            }
            if (indexPath.section ==0 && indexPath.row ==3) return 100;
            if (indexPath.section ==0 && indexPath.row ==0) return 40;
        }
        if (indexPath.section == 2) return 50;
        return 70;
    }
    else return 50;
}

- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        CGRect frame = textView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]) {
        if (indexPath.section == 2){
            if (indexPath.row != 0) {
                return YES;
            }
        }
    }
    if (indexPath.section == 1){
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
        for (NSString *commentDico in _sampleDataArray){
            NSString *commenterId = [commentDico substringToIndex:10];
            [commenters addObject:commenterId];
            if ([commenterId isEqualToString:[PFUser currentUser].objectId]) {
                [indexes addIndex:[_sampleDataArray indexOfObject:commentDico]];
                
            }
        }
        if ([indexes containsIndex:indexPath.row])return YES;
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2){
        PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
        [query whereKey:@"user" equalTo:[group[@"Identities"] objectAtIndex:indexPath.row]];
        [query whereKey:@"objectId" equalTo:group[@"objectId"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 for (PFObject *object in objects) {
                     [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          if (error != nil) [ProgressHUD showError:@"Network error."];
                      }];
                 }
             }
             else [ProgressHUD showError:@"Network error."];
         }];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
        [query2 whereKey:@"objectId" equalTo:group[@"objectId"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 for (PFObject *object in objects) {
                     [object[@"members"] removeObject:[group[@"Users"] objectAtIndex:indexPath.row]];
                     [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          if (error != nil) {
                              [ProgressHUD showError:@"Network error."];
                          } else {
                              SendNotificationAboutRemovingSomeone(group, [group[@"Users"] objectAtIndex:indexPath.row], @"event");
                          }
                      }];
                 }
             }
             else [ProgressHUD showError:@"Network error."];
         }];
        
        
        group[@"Affluence"] = @([group[@"Affluence"] integerValue]-1);
        [group[@"Identities"] removeObjectAtIndex:indexPath.row];
    }
    
    if (indexPath.section == 1){
        [_sampleDataArray removeObjectAtIndex:indexPath.row];
        group[@"Comments"] = _sampleDataArray;
    }
    
    [group saveInBackgroundWithBlock :^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }];
    
}
- (IBAction)actionPhoto:(id)sender

{
    if ([group[@"Identities"] containsObject:[[PFUser currentUser] objectId]]){
        cameraOrKeyboard = YES;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Select the new cover photo", @"Share a moment", nil];
        [action showFromTabBar:[[self tabBarController] tabBar]];
    }
}

-(void)takeNormalPicture{
    PresentPhotoLibrary(self, YES);
    galleryOrMain = YES;
}

-(void)takeMainPicture{
    PresentPhotoLibrary(self, YES);
    galleryOrMain = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    if (galleryOrMain == NO){
        UIImage *image = info[UIImagePickerControllerEditedImage];
        UIImage *picture = ResizeImage(image, 280, 280);
        UIImage *thumbnail = ResizeImage(image, 60, 60);
        eventImage.image = picture;
        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
        [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
        group[@"Picture"] = filePicture;
        group[@"Thumbnail"]= fileThumbnail;
        
    }else{
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
        UIImage *picture = ResizeImage(image, 414, 414);
        UIImage *thumbnail = ResizeImage(image, 137, 137);
        self.fileP = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        self.fileT = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
        
        ImageController *imageController = [[ImageController alloc]init];
        imageController.image = picture;
        imageController.array = nil;
        imageController.delegate = self;
        [self.navigationController pushViewController:imageController animated:YES];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
         [picker dismissViewControllerAnimated:YES completion:nil];
     }];
    
}

-(void)actionShare:(NSString *)info{
    [filePictureBank addObject:self.fileP];
    [fileBank addObject:self.fileT];
    [captions addObject:info];
    //group[@"thumbnailFiles"] = fileBank;
    group[@"pictureFiles"] = filePictureBank;
    group[@"captions"] = captions;
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
}


- (void)actionWrite

{
    cameraOrKeyboard = NO;
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Chat", @"Advise", nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

- (void)actionReport
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Report this event for inappropriate content. Upon confirmation from the Ocur team, this event will be cancelled and no user will be able to access its information. The author of the inappropriate content will also be flagged." delegate:self cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
    action.tag = 1;
    [action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (actionSheet.tag == 1){
        NSLog(@"User %@ reported.",group.objectId);
        PFObject *report = [PFObject objectWithClassName:@"Reports"];
        report[@"object"] = group.objectId;
        report[@"date"] = [NSDate date];
        report[@"reported"] = [PFUser currentUser].objectId;
        [report saveInBackground];
    } else {
    
    if (cameraOrKeyboard){
        if (buttonIndex != actionSheet.cancelButtonIndex){
            if (buttonIndex == 0)
            {
                [self takeMainPicture];
            }
            if (buttonIndex == 1)
            {
                [self takeNormalPicture];
            }
        }
        
    } else{
        if (buttonIndex != actionSheet.cancelButtonIndex){
            if (buttonIndex == 1)
            {
                [self commentAction];
            }
            if (buttonIndex == 0)
            {
                [self actionChat];
            }
        }
    }
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            BOOL check = NO;
            if (cell == self.cellDescription) {
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
            
            
            
        }
        
    }
    
    
}



#warning changed

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
    group[@"Description"] = textView.text;
    [group saveInBackground];
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
            bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            cell.backgroundView = bgView;
            
        }
        
    }
    
    [textView resignFirstResponder];
    
}



- (IBAction)actionLocation:(id)sender {
    if ([group[@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
        SearchController *search = [[SearchController alloc]init];
        search.event = group;
        search.delegate = self;
        [self.navigationController pushViewController:search animated:YES];
    } else {
        double latitude = [[group[@"Location"] objectForKey:@"lat"] doubleValue];
        double longitude = [[group[@"Location"] objectForKey:@"long"] doubleValue];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:group[@"Name"]];
        [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    }
    
}

-(void)choseNewLocation:(NSDictionary *)location{
    group[@"Location"] = location;
    group[@"LocationString"] = [location objectForKey:@"string"];
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error){
            [ProgressHUD showError:@"Could not save new lieu"];
        }else{
            [self.locationButton setTitle:group[@"LocationString"] forState:UIControlStateNormal];
            [self updateMapWithEvent];
            PFUser *user = [PFUser currentUser];
            [self sendNotif:[NSString stringWithFormat:@"%@ changed the location of %@ to %@",user[PF_USER_FULLNAME],group[@"Name"],[location objectForKey:@"adress"]]];
        }
    }];
}




@end