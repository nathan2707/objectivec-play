//
//  myButton.h
//  Livit
//
//  Created by Nathan on 1/11/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface myButton : UIButton
@property (nonatomic,strong) PFObject *house;
@property (nonatomic, strong) NSString *userId;
@end
