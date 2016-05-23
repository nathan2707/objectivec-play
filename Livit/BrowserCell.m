//
//  BrowserCell.m
//  Livit
//
//  Created by Nathan on 1/4/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "BrowserCell.h"

@implementation BrowserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.likeView setHidden:YES];
    self.descriptionTextView.userInteractionEnabled = NO;
}
- (IBAction)liked:(id)sender {
//    if ([sender imageForState:UIControlStateNormal] == [UIImage imageNamed:@"like"]){
//        [sender setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
//    } else {
//        [sender setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
//    }
}

@end
