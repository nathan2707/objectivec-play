//
//  CatCell.h
//  Livit
//
//  Created by Nathan on 12/26/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CatCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *logoView;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *selectedView;



@end
