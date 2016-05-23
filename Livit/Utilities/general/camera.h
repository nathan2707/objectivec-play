//
//  camera.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>

BOOL			PresentPhotoCamera		(id target, BOOL canEdit);
BOOL			PresentVideoCamera		(id target, BOOL canEdit);
BOOL			PresentMultiCamera		(id target, BOOL canEdit);

BOOL			PresentPhotoLibrary		(id target, BOOL canEdit);
BOOL			PresentVideoLibrary		(id target, BOOL canEdit);
