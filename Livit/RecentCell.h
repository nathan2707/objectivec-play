//
//  RecentCell.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface RecentCell : UITableViewCell

- (void)bindData:(PFObject *)recent_;
@property (strong, nonatomic) IBOutlet UILabel *labelPeople;
@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSDate *date;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@end
