//
//  GalleryView.m
//  Livit
//
//  Created by Nathan on 12/24/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "GalleryView.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"
#import "ImageController.h"
#import "AppConstant.h"
#import "common.h"
#import "group.h"
#import "recent.h"
#import "push.h"
#import "image.h"
#import "camera.h"
#import "MWPhotoBrowser.h"
#import "GroupsView.h"
#import "CreateGroupView.h"
#import "GroupSettingsView.h"
#import "NavigationController.h"
#import "UserCell.h"
#import "EventCell.h"
#import "PhotoCell.h"
#import "HousesController.h"

#import "PickCell.h"
@interface GalleryView () <MWPhotoBrowserDelegate, ImageDelegate,UIActionSheetDelegate>
{
    NSMutableArray *fileBank;
    NSMutableArray *filePictureBank;
    NSMutableArray *photos;
    NSMutableArray *captions;
    BOOL comingFromCreate;
    BOOL done;
    int selected;
    NSMutableArray *imagePicked;
    UIActivityIndicatorView *indicator;
    
}
@property (strong, nonatomic) IBOutlet UICollectionViewCell *selectCell;
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) NSString *imageUrl;
@end

@implementation GalleryView

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([self.navigationController.viewControllers objectAtIndex:0].view.frame.size.width/3 - 0.5,[self.navigationController.viewControllers objectAtIndex:0].view.frame.size.width/3 - 0.5);
    layout.minimumInteritemSpacing = 0.5;
    layout.minimumLineSpacing = 0.5;
    return (self = [super initWithCollectionViewLayout:layout]);
}

-(void)actionNextReal:(UIButton*)sender{
    if (sender.tag == 0){
        NSData *dataToSave = [NSData dataWithContentsOfURL:[NSURL URLWithString:[filePictureBank objectAtIndex:selected-1]]];
        if (dataToSave != nil){
            PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:dataToSave];
            self.theEventFromCreateMode[@"Picture"] = filePicture;
        } else {
            UIImage *image = [imagePicked objectAtIndex:selected-1];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:imageData];
            self.theEventFromCreateMode[@"Picture"] = filePicture;
        }
        
        HousesController *hc = [[HousesController alloc]init];
        hc.event = self.theEventFromCreateMode;
        [self.navigationController pushViewController:hc animated:YES];
    } else {
        [self.theEventFromCreateMode saveInBackground];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gallery";
    if (self.theEventFromCreateMode != nil) comingFromCreate = YES;
    else comingFromCreate = NO;
    done = NO;
    selected = 0;
    imagePicked = [[NSMutableArray alloc]init];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    self.collectionView.bounces = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    photos = [[NSMutableArray alloc]init];
    
    if (comingFromCreate){
        [self.collectionView registerNib:[UINib nibWithNibName:@"PickCell" bundle:nil] forCellWithReuseIdentifier:@"PickCell"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionNextReal:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.theEventFromCreateMode[@"Creator"] isEqualToString:[PFUser currentUser].objectId]){
            button.tag = 1;
            [button setTitle:@"Save" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.frame = CGRectMake(0,0,50,35);
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            self.navigationItem.rightBarButtonItem = barButton;
        } else {
            button.tag = 0;
            [button setTitle:@"Next" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.frame = CGRectMake(0,0,50,35);
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            self.navigationItem.rightBarButtonItem = barButton;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
        
        [self findPhotoforvenue:self.venue];
        
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        [indicator startAnimating];
        
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(actionCamera)];
        fileBank = [[NSMutableArray alloc] initWithArray:[self.house objectForKey:@"thumbnailFiles"]];
        filePictureBank = [[NSMutableArray alloc] initWithArray:[self.house objectForKey:@"pictureFiles"]];
        captions = [[NSMutableArray alloc]initWithArray:[self.house objectForKey:@"captions"]];
        [self loadBrowser];
    }
    
    
    done = YES;
    
    //    [self loadBrowser];
    //    [self.collectionView reloadData];
    
}
-(void)findPhotoforvenue:(FSVenue*)venue{
    [Foursquare2 venueGetPhotos:venue.venueId limit:[NSNumber numberWithInt:11] offset:[NSNumber numberWithInt:0] callback:^(BOOL success, id result) {
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        NSArray *quick = [NSArray arrayWithArray:[[[result objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"]];
        if (quick.count != 0){
            
            NSString * prefixe = [[[[[result objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"prefix"];
            NSString *suffixe = [[[[[result objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"suffix"];
            NSString *url = [[prefixe stringByAppendingString:@"original"] stringByAppendingString:suffixe];
            //NSString *urlSmall = [[prefixe stringByAppendingString:[NSString stringWithFormat:@"%ix%i",(int)self.view.frame.size.width/3,(int)self.view.frame.size.width/3]] stringByAppendingString:suffixe];
            PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            
            self.theEventFromCreateMode[@"Picture"] = filePicture;
            
            //NSMutableArray *urls = [[NSMutableArray alloc]initWithObjects:urlSmall, nil];
            NSMutableArray *propositionFiles = [[NSMutableArray alloc]initWithObjects:url, nil];
            for (int i = 1;i<quick.count;i++){
                NSString * prefixe = [[[[[result objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:i] objectForKey:@"prefix"];
                NSString *suffixe = [[[[[result objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:i] objectForKey:@"suffix"];
                NSString *url = [[prefixe stringByAppendingString:@"original"] stringByAppendingString:suffixe];
                [propositionFiles addObject:url];
            }
            self.theEventFromCreateMode[@"PropositionsThumbnailUrls"] = propositionFiles;
            self.theEventFromCreateMode[@"Propositions"] = propositionFiles;
        }
        
        fileBank = [[NSMutableArray alloc] initWithArray:[self.theEventFromCreateMode objectForKey:@"PropositionsThumbnailUrls"]];
        filePictureBank = [[NSMutableArray alloc] initWithArray:[self.theEventFromCreateMode objectForKey:@"Propositions"]];
        
        [self loadBrowser];
        [self.collectionView reloadData];
        
        
    }];
    
}

-(void)actionCamera{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Take photo", @"Choose from library", nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0)
        {
            PresentMultiCamera(self, YES);
        }
        if (buttonIndex == 1)
        {
            PresentPhotoLibrary(self,YES);
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    [imagePicked addObject:info[UIImagePickerControllerEditedImage]];
//    UIImage *picture = ResizeImage([imagePicked lastObject], 414, 414);
//    UIImage *thumbnail = ResizeImage([imagePicked lastObject], self.view.frame.size.width/3 - 0.5, self.view.frame.size.width/3 - 0.5);
    self.imageUrl = [NSString stringWithFormat:@"%@",[info valueForKey:UIImagePickerControllerReferenceURL]];
//    self.fileP = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
//    self.fileT = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    
    if (comingFromCreate){
        [filePictureBank insertObject:self.imageUrl atIndex:0];
        [fileBank insertObject:self.imageUrl atIndex:0];
        [self loadBrowser];
        [self.collectionView reloadData];
        
    }else{
        
        ImageController *imageController = [[ImageController alloc]init];
        imageController.image = [imagePicked lastObject];;
        imageController.array = self.events;
        imageController.delegate = self;
        [self.navigationController pushViewController:imageController animated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionShare:(NSString *)info{
    UIImage *image = [imagePicked lastObject];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:imageData];
    
    UIImage *thumbnail = ResizeImage(image, self.view.frame.size.width/3 - 0.5,self.view.frame.size.width/3 - 0.5);
    NSData *imageData2 = UIImageJPEGRepresentation(thumbnail, 1.0);
    PFFile *fileThumbnail = [PFFile fileWithName:@"picture.jpg" data:imageData2];
    
    
    [filePictureBank addObject:filePicture];
    [fileBank addObject:fileThumbnail];
    [captions addObject:info];
    self.house[@"thumbnailFiles"] = fileBank;
    self.house[@"pictureFiles"] = filePictureBank;
    self.house[@"captions"] = captions;
    
    [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
           [ProgressHUD showError:@"Network error."];
         } else {
         [self loadBrowser];
         [self.collectionView reloadData];
         }
     }];
}


#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (comingFromCreate) return fileBank.count+1;
    return filePictureBank.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (done){
        
        if (comingFromCreate) {
            if (indexPath.item == 0){
                PickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickCell" forIndexPath:indexPath];
                [cell.pickButton addTarget:self action:@selector(actionCamera) forControlEvents:UIControlEventTouchUpInside];
                
                AVCaptureSession *session = [[AVCaptureSession alloc] init];
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!input) {
                    NSLog(@"Couldn't create video capture device");
                } else {
                [session addInput:input];
                }
                AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
                previewLayer.frame = cell.bounds;
                [cell.layer addSublayer:previewLayer];
                
                return cell;
            } else {
                PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
                UIImage *ourImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[fileBank objectAtIndex:indexPath.item-1]]]];
                if (ourImage == nil) ourImage = [imagePicked objectAtIndex:indexPath.item - 1];
                cell.selectedButton.tag = indexPath.item;
                [cell.selectedButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
                if (selected == indexPath.item) {
                    [cell.selectedButton setImage:[UIImage imageNamed:@"OK-32" ] forState:UIControlStateNormal];
                    cell.selectedButton.alpha =1;
                } else {
                    [cell.selectedButton setImage:[UIImage imageNamed:@"Full Moon Filled-32" ] forState:UIControlStateNormal];
                    cell.selectedButton.alpha =.3;
                }
                cell.imageView.image  = ourImage;
                [cell.imageView loadInBackground];
                return cell;
            }
        } else {
            PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
            [cell.selectedButton setHidden:YES];
            
//            if (imagePicked.count > indexPath.item){
//                UIImage *ourImage = [imagePicked objectAtIndex:indexPath.item];
//                ourImage = ResizeImage(ourImage, self.view.frame.size.width/3 - 0.5,self.view.frame.size.width/3 - 0.5);
//                [cell.imageView setImage:ourImage];
//            } else {
                [cell.imageView setFile:[[self.house objectForKey:@"pictureFiles"]objectAtIndex:indexPath.item]];
                [cell.imageView loadInBackground];
//            }
            
            return cell;
        }
    }
    return nil;
}

-(void)selectImage:(UIButton*)sender{
    if (selected != sender.tag){
        [sender setImage:[UIImage imageNamed:@"ImageOn" ] forState:UIControlStateNormal];
        selected = (int)sender.tag;
        [self.collectionView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
        [sender setImage:[UIImage imageNamed:@"Full Moon Filled-32" ] forState:UIControlStateNormal];
        selected = 0;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    // Customise selection images to change colours if required
    browser.customImageSelectedIconName = @"ImageSelected.png";
    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:1];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
    
    // Manipulate
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    [browser setCurrentPhotoIndex:10];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count) {
        return [photos objectAtIndex:index];
    }
    return nil;
}

-(void)loadBrowser{
    [photos removeAllObjects];
    for (int i = 0; i<fileBank.count; i++){
        MWPhoto *photo;
        if (comingFromCreate){
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:[filePictureBank objectAtIndex:i]]];
        } else {
            PFFile *imageFile = [filePictureBank objectAtIndex:i];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageFile.url]];
            photo.caption = [captions objectAtIndex:i];
        }
        [photos addObject:photo];
    }
}


@end
