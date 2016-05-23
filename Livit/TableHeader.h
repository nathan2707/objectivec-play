//
//  TableHeader.h
//  Livit
//
//  Created by Nathan on 1/4/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "myButton.h"
@interface TableHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) IBOutlet UIView *bv;
@property (strong, nonatomic) IBOutlet myButton *buttonCategory;
@property (strong, nonatomic) IBOutlet myButton *adressButton;

@property (strong, nonatomic) IBOutlet UIButton *nameButton;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
-(void)drawHeader;
@property (nonatomic,strong) PFObject *event;
@end
