//
//  myTap.h
//  Livit
//
//  Created by Nathan on 1/18/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myTap : UITapGestureRecognizer
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong) NSDictionary *coordinates1;
@property (nonatomic,assign) int index;
@end
