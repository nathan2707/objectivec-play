//
//  fileutil.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "fileutil.h"

NSString* Applications(NSString *file)
{
	NSString *path = [[NSBundle mainBundle] resourcePath];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	return path;
}

NSString* Documents(NSString *file)
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	return path;
}

NSString* Caches(NSString *file)
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	return path;
}
