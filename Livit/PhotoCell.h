//
//  PhotoCell.h
//  Livit
//
//  Created by Nathan on 12/24/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
@interface PhotoCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet PFImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *selectedButton;

@end
