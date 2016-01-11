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

    self.descriptionTextView.userInteractionEnabled = NO;
}

@end
