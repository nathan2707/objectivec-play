//
//  PFUser+Util.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (Util)

- (NSString *)fullname;

- (BOOL)isEqualTo:(PFUser *)user;

@end
