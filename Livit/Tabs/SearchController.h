//
//  SearchController.h
//  Livit
//
//  Created by Nathan on 11/30/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol SearchLocationDelegate
-(void)choseNewLocation:(NSDictionary*)location;
@end

@interface SearchController : UIViewController
@property (nonatomic,strong) PFObject *event;
@property (nonatomic, assign) NSObject <SearchLocationDelegate> *delegate;
@end
