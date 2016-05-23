//
//  push.h
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			ParsePushUserAssign		(void);
void			ParsePushUserResign		(void);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			SendPushNotification	(NSString *groupId, NSString *text);
void            SendNotificationAboutAddingNumberOfPeople    (PFObject *house,NSArray *additions,NSString *eventOrHouse);
void            SendNotificationAboutAddingSomeoneToHouse           (PFObject *house,PFUser *user_);
void SendNotificationAboutRequestingToJoin(PFObject *house,NSString *eventOrHouse);
void SendNotificationAboutRemovingSomeone(PFObject *house,PFUser *user_,NSString *eventOrHouse);
void SendNotificationAboutAcceptingInvitation(PFObject *group_,NSString *eventOrHouse);
void SendNotificationAboutInvitingToEvent(PFObject *group,NSArray *names,NSArray *ID);
void SendNotificationAboutLeaving(PFObject *house,NSString *eventOrHouse);
void SendNotificationAboutAcceptingRequest(PFObject *house,PFUser *user_,NSString *eventOrHouse);
void SendNotificationAboutAddingToHouse(PFObject *group,NSArray *names,NSArray *IDs);