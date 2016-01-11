//
//  ImageController.h
//  Livit
//
//  Created by Nathan on 12/25/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ImageDelegate <NSObject>

-(void)actionShare:(NSString*)info;

@end

@interface ImageController : UITableViewController
@property (nonatomic, assign) NSObject<ImageDelegate> *delegate;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSMutableArray *array;
@end
