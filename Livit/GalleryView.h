//
//  GalleryView.h
//  Livit
//
//  Created by Nathan on 12/24/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface GalleryView : UICollectionViewController
@property (strong, nonatomic) PFObject *house;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) PFFile *fileP;
@property (strong, nonatomic) PFFile *fileT;
@end
