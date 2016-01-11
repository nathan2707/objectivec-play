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

@interface GalleryView () <MWPhotoBrowserDelegate, ImageDelegate>
{
    NSMutableArray *fileBank;
    NSMutableArray *filePictureBank;
    NSMutableArray *photos;
    NSMutableArray *captions;
}
@end

@implementation GalleryView

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(137.0, 137.0);
    layout.minimumInteritemSpacing = 0.5;
    layout.minimumLineSpacing = 0.5;
    return (self = [super initWithCollectionViewLayout:layout]);
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Gallery";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(actionCamera)];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    self.collectionView.bounces = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    fileBank = [[NSMutableArray alloc] initWithArray:[self.house objectForKey:@"thumbnailFiles"]];
    filePictureBank = [[NSMutableArray alloc] initWithArray:[self.house objectForKey:@"pictureFiles"]];
    captions = [[NSMutableArray alloc]initWithArray:[self.house objectForKey:@"captions"]];

    photos = [[NSMutableArray alloc]init];
    }

-(void)actionCamera{
    PresentPhotoLibrary(self, YES);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    UIImage *picture = ResizeImage(image, 414, 414);
    UIImage *thumbnail = ResizeImage(image, 137, 137);
    self.fileP = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    self.fileT = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
    
    ImageController *imageController = [[ImageController alloc]init];
    imageController.image = picture;
    imageController.array = self.events;
    imageController.delegate = self;
    [self.navigationController pushViewController:imageController animated:YES];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionShare:(NSString *)info{
    [filePictureBank addObject:self.fileP];
    [fileBank addObject:self.fileT];
    [captions addObject:info];
    self.house[@"thumbnailFiles"] = fileBank;
    self.house[@"pictureFiles"] = filePictureBank;
    self.house[@"captions"] = captions;
    [self.collectionView reloadData];
    [self.house saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
}

-(void)viewDidAppear:(BOOL)animated{
    for (int i = 0; i<fileBank.count; i++){
        PFFile *imageFile = [filePictureBank objectAtIndex:i];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageFile.url]];
        photo.caption = [captions objectAtIndex:i];
        [photos addObject:photo];
    }
}


#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return fileBank.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [cell.imageView setFile:[[self.house objectForKey:@"thumbnailFiles"]objectAtIndex:indexPath.row]];
    [cell.imageView loadInBackground];
    return cell;
    
    return cell;
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



@end
