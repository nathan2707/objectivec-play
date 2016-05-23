//
//  push.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "push.h"

void ParsePushUserAssign(void)

{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser].objectId;
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
		}
	}];
}

void ParsePushUserResign(void)
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	[installation removeObjectForKey:PF_INSTALLATION_USER];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
}

void SendPushNotification(NSString *groupId, NSString *text)
{
	PFUser *user = [PFUser currentUser];
	NSString *message = [NSString stringWithFormat:@"%@: %@", user[PF_USER_FULLNAME], text];
	PFPush *push = [[PFPush alloc] init];
    [push setChannel: [@"h" stringByAppendingString:groupId]];
	[push setMessage:message];
	[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"SendPushNotification send error.");
		}
	}];
}

void SendNotificationAboutAddingNumberOfPeople(PFObject *house,NSArray *additions,NSString *eventOrHouse)
{

        PFUser *user = [PFUser currentUser];
        NSDictionary *data;
        if ([eventOrHouse isEqualToString:@"event"]){
        data = @{
                               @"badge" : @"Increment",
                               @"info" : @"GroupSettingsView",
                               @"alert": [NSString stringWithFormat:@"%@ invited %lu people to %@.",user[PF_USER_FULLNAME],(unsigned long)additions.count,house[@"Name"]]
                               };
        } else {
        data = @{
                     @"badge" : @"Increment",
                     @"info" : @"GroupsView",
                     @"alert": [NSString stringWithFormat:@"%@ added %lu people to %@.",user[PF_USER_FULLNAME],(unsigned long)additions.count,house[@"Name"]]
                     };
        }
        PFPush *push = [[PFPush alloc] init];
    
        [push setChannel:[@"h" stringByAppendingString:house.objectId]];
        [push setData:data];
        [push sendPushInBackground];
}

void SendNotificationAboutAddingToHouse(PFObject *group,NSArray *names,NSArray *IDs)
{
    NSString *message;
    switch (names.count) {
        case 1:
            message = [names firstObject];
            break;
        case 2:
            message = [NSString stringWithFormat:@"%@ and %@", [names firstObject], [names lastObject]];
            break;
        case 3:
            message = [NSString stringWithFormat:@"%@, %@ and %@", [names firstObject],names[1] ,[names lastObject]];
            break;
        default:
            message = [NSString stringWithFormat:@"%@, %@, %@ and %lu others", [names firstObject],names[1] ,names[2],names.count-3];
            break;
    }
    PFUser *user = [PFUser currentUser];
     NSDictionary   *data = @{
                             @"badge" : @"Increment",
                             @"info" : @"GroupsView",
                             @"alert": [NSString stringWithFormat:@"%@ added %@ to %@.",user[PF_USER_FULLNAME],message,group[@"Name"]]
                             };
    PFPush *pushHouse = [[PFPush alloc] init];
    [pushHouse setChannel:[@"h" stringByAppendingString:group.objectId]];
    [pushHouse setData:data];
    [pushHouse sendPushInBackground];
    
    
        // Find devices associated with these users
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" containedIn:IDs];
                PFPush *pushTarget = [[PFPush alloc] init];
                [pushTarget setQuery:pushQuery]; // Set our Installation query
                PFUser *userInviting = [PFUser currentUser];
                NSDictionary *dataTarget = @{
                                             @"badge" : @"Increment",
                                             @"info" : @"InvitesView",
                                             @"alert":[NSString stringWithFormat:@"%@ invited you to %@.",userInviting[PF_USER_FULLNAME],group[@"Name"]]
                                             };
                [pushTarget setData:dataTarget];
                [pushTarget sendPushInBackground];

}

void SendNotificationAboutAddingSomeoneToHouse(PFObject *house,PFUser *userToAdd)

{
    PFUser *user = [PFUser currentUser];
    NSDictionary *data0 = @{
                           @"badge" : @"no",
                           @"info" : @"GroupsView",
                           @"alert": [NSString stringWithFormat:@"%@ added you to %@.",user[PF_USER_FULLNAME],house[@"Name"]]
                           };
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:userToAdd.objectId];
    PFPush *push0 = [[PFPush alloc] init];
    [push0 setQuery:pushQuery];
    [push0 setData:data0];
    [push0 sendPushInBackground];
    
    
    NSDictionary *data = @{
                            @"badge" : @"no",
                            @"info" : @"GroupsView",
                            @"alert": [NSString stringWithFormat:@"%@ added %@ to %@.",user[PF_USER_FULLNAME],userToAdd[PF_USER_FULLNAME],house[@"Name"]]
                                   };
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[@"h" stringByAppendingString:house.objectId]];
            [push setData:data];
            [push sendPushInBackground];
            
    
}

void SendNotificationAboutRequestingToJoin(PFObject *house,NSString *eventOrHouse)

{
    NSDictionary *data;
    PFUser *user = [PFUser currentUser];
    if ([eventOrHouse isEqualToString:@"event"]){
        data = @{
                 @"badge" : @"Increment",
                 @"info" : @"GroupSettingsView",
                 @"alert": [NSString stringWithFormat:@"%@ requested to join %@.",user[PF_USER_FULLNAME],house[@"Name"]]
                 };
    } else {
        data = @{
                 @"badge" : @"Increment",
                 @"info" : @"GroupsView",
                 @"alert":[NSString stringWithFormat:@"%@ requested to join %@.",user[PF_USER_FULLNAME],house[@"Name"]]
                 };
    }

            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[@"h" stringByAppendingString:house.objectId]];
            [push setData:data];
            [push sendPushInBackground];
    
}


void SendNotificationAboutRemovingSomeone(PFObject *house,PFUser *user_,NSString *eventOrHouse)

{

            NSDictionary *data;
            PFUser *user = [PFUser currentUser];
            if ([eventOrHouse isEqualToString:@"event"]){
                data = @{
                         @"badge" : @"no",
                         @"info" : @"GroupSettingsView",
                         @"alert":[NSString stringWithFormat:@"%@ removed %@ of%@.",user[PF_USER_FULLNAME],user_[PF_USER_FULLNAME],house[@"Name"]]
                         };
            } else {
                data = @{
                         @"badge" : @"no",
                         @"info" : @"GroupsView",
                         @"alert": [NSString stringWithFormat:@"%@ removed %@ of%@.",user[PF_USER_FULLNAME],user_[PF_USER_FULLNAME],house[@"Name"]]
                         };
            }

            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[@"h" stringByAppendingString:house.objectId]];
            [push setData:data];
            [push sendPushInBackground];
    
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:user_.objectId];
            NSDictionary *dataTarget = @{
                                         @"badge" : @"no",
                                         @"info" : @"GroupSettingsView",
                                         @"alert":[NSString stringWithFormat:@"You've been removed from %@.",house[@"Name"]]
                                         };
            
            PFPush *pushTarget = [[PFPush alloc] init];
            [pushTarget setQuery:pushQuery]; // Set our Installation query
            [pushTarget setData:dataTarget];
            [pushTarget sendPushInBackground];
    
}

void SendNotificationAboutLeaving(PFObject *house,NSString *eventOrHouse)

{
    PFUser *user = [PFUser currentUser];

            NSDictionary *data;
            if ([eventOrHouse isEqualToString:@"event"]){
                data = @{
                         @"badge" : @"no",
                         @"info" : @"GroupSettingsView",
                         @"alert":[NSString stringWithFormat:@"%@ left %@.",user[PF_USER_FULLNAME],house[@"Name"]]
                         };
            } else {
                data = @{
                         @"badge" : @"no",
                         @"info" : @"GroupsView",
                         @"alert":[NSString stringWithFormat:@"%@ left %@.",user[PF_USER_FULLNAME],house[@"Name"]]
                         };
            }
            
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[@"h" stringByAppendingString:house.objectId]];
            [push setData:data];
            [push sendPushInBackground];
}



void SendNotificationAboutAcceptingInvitation(PFObject *group_,NSString *eventOrHouse)
{

        PFUser *user = [PFUser currentUser];
        
        
        NSDictionary *data;
        if ([eventOrHouse isEqualToString:@"event"]){
            data = @{
                     @"badge" : @"no",
                     @"info" : @"GroupSettingsView",
                     @"alert": [NSString stringWithFormat:@"%@ is going to %@.",user[PF_USER_FULLNAME],group_[@"Name"]]
                     };
        } else {
            data = @{
                     @"badge" : @"no",
                     @"info" : @"GroupsView",
                     @"alert": [NSString stringWithFormat:@"%@ joined %@.",user[PF_USER_FULLNAME],group_[@"Name"]]
                     };
        }
        
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[@"h" stringByAppendingString:group_.objectId]];
        [push setData:data];
        [push sendPushInBackground];

}

void SendNotificationAboutInvitingToEvent(PFObject *group,NSArray *names,NSArray *IDs)
{


NSString *message;
    switch (names.count) {
        case 1:
            message = [names firstObject];
            break;
        case 2:
            message = [NSString stringWithFormat:@"%@ and %@", [names firstObject], [names lastObject]];
            break;
        case 3:
            message = [NSString stringWithFormat:@"%@, %@ and %@", [names firstObject],names[1] ,[names lastObject]];
            break;
        default:
            message = [NSString stringWithFormat:@"%@, %@, %@ and %lu more", [names firstObject],names[1] ,names[2],names.count-3];
            break;
    }
    PFUser *user = [PFUser currentUser];
    NSDictionary   *data = @{
                             @"badge" : @"Increment",
                             @"info" : @"GroupSettingsView",
                             @"alert": [NSString stringWithFormat:@"%@ invited %@ to %@.",user[PF_USER_FULLNAME],message,group[@"Name"]]
                             };

PFPush *pushHouse = [[PFPush alloc] init];
[pushHouse setChannel:[@"h" stringByAppendingString:group.objectId]];

[pushHouse setData:data];
[pushHouse sendPushInBackground];





for (int i =0;i<names.count;i++){
// Find devices associated with these users
PFQuery *pushQuery = [PFInstallation query];
[pushQuery whereKey:@"user" equalTo:[IDs objectAtIndex:i]];
// Send push notification to query
PFPush *pushTarget = [[PFPush alloc] init];
[pushTarget setQuery:pushQuery]; // Set our Installation query
PFUser *userInviting = [PFUser currentUser];
NSDictionary *dataTarget = @{
                                 @"badge" : @"Increment",
                                 @"info" : @"InvitesView",
                                 @"alert": [NSString stringWithFormat:@"%@ invited you to %@.",userInviting[PF_USER_FULLNAME],group[@"Name"]]
                                 };
[pushTarget setData:dataTarget];
[pushTarget sendPushInBackground];
    }
}

void SendNotificationAboutAcceptingRequest(PFObject *house,PFUser *user_,NSString *eventOrHouse){

            PFPush *push = [[PFPush alloc] init];
            NSDictionary *data;
            if ([eventOrHouse isEqualToString:@"event"]){
                data = @{
                         @"badge" : @"Increment",
                         @"info" : @"GroupSettingsView",
                         @"alert": [NSString stringWithFormat:@"%@ is going to %@.",user_[PF_USER_FULLNAME],house[@"Name"]]
                         };
            } else {
                data = @{
                         @"badge" : @"Increment",
                         @"info" : @"GroupsView",
                         @"alert":[NSString stringWithFormat:@"%@ joined %@.",user_[PF_USER_FULLNAME],house[@"Name"]]
                         };
                           }
            [push setChannel:[@"h" stringByAppendingString:house.objectId]];
            [push setData:data];

            
            [push sendPushInBackground];
            NSDictionary *dataTarget = @{
                                         @"badge" : @"Increment",
                                         @"info" : @"GroupSettingsView",
                                         @"alert":[NSString stringWithFormat:@"You've been added to %@.",house[@"Name"]]
                                         };
    
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:user_.objectId];
            PFPush *pushTarget = [[PFPush alloc] init];
            [pushTarget setQuery:pushQuery]; // Set our Installation query
            [pushTarget setData:dataTarget];
            [pushTarget sendPushInBackground];


}


