//
//  SearchCell.h
//  Livit
//
//  Created by Nathan on 11/20/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SearchCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *selectedView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property(nonatomic,strong) NSDictionary *location;

@end
