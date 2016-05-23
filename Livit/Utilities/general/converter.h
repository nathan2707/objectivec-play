//
//  converter.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString*		Date2String				(NSDate *date);
NSDate*			String2Date				(NSString *dateStr);

NSString*		TimeElapsed				(NSTimeInterval seconds);
