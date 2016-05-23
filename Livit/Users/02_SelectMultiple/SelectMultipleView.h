//
//  SelectMultipleView.h
//  Livit
//
//  Created by Nathan on 12/5/15.
//  Copyright © 2015 Nathan. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol SelectMultipleDelegate

- (void)didSelectMultipleUsers:(NSMutableArray *)users;

@end

@interface SelectMultipleView : UITableViewController

@property (nonatomic, assign) IBOutlet id<SelectMultipleDelegate>delegate;

@end
