//
//  image.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

UIImage*		SquareImage				(UIImage *image, CGFloat size);
UIImage*		ResizeImage				(UIImage *image, CGFloat width, CGFloat height);
UIImage*		CropImage				(UIImage *image, CGFloat x, CGFloat y, CGFloat width, CGFloat height);
