//
//  PFUser+Util.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "AppConstant.h"

#import "PFUser+Util.h"

@implementation PFUser (Util)

- (NSString *)fullname

{
	return self[PF_USER_FULLNAME];
}

- (BOOL)isEqualTo:(PFUser *)user

{
	return [self.objectId isEqualToString:user.objectId];
}

@end
