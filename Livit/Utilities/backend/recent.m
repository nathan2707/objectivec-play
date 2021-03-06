//
//  recent.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFUser+Util.h"

#import "AppConstant.h"

#import "recent.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartPrivateChat(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *id1 = user1.objectId;
    NSString *id2 = user2.objectId;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSArray *members = @[user1.objectId, user2.objectId];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CreateRecentItem(user1, groupId, members, user2[PF_USER_FULLNAME],@"",nil);
    CreateRecentItem(user2, groupId, members, user1[PF_USER_FULLNAME],@"",nil);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return groupId;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartMultipleChat(NSMutableArray *users)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *groupId = @"";
    NSString *description = @"";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [users addObject:[PFUser currentUser]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (PFUser *user in users)
    {
        [userIds addObject:user.objectId];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSArray *sorted = [userIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (NSString *userId in sorted)
    {
        groupId = [groupId stringByAppendingString:userId];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (PFUser *user in users)
    {
        if ([description length] != 0) description = [description stringByAppendingString:@" & "];
        description = [description stringByAppendingString:user[PF_USER_FULLNAME]];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (PFUser *user in users)
    {
        CreateRecentItem(user, groupId, userIds, description, @"",nil);
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return groupId;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem(PFUser *user, NSString *groupId, NSArray *members, NSString *description, NSString *category, PFObject *event)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//                 NSMutableDictionary *recent = [[NSMutableDictionary alloc]initWithCapacity:9];
//                 recent[@"Category"] = category;
//                 recent[PF_RECENT_USER] = user;
//                 recent[PF_RECENT_GROUPID] = groupId;
//                 recent[PF_RECENT_MEMBERS] = members;
//                 recent[PF_RECENT_DESCRIPTION] = description;
//                 recent[PF_RECENT_LASTUSER] = [PFUser currentUser];
//                 recent[PF_RECENT_LASTMESSAGE] = @"";
//                 recent[PF_RECENT_COUNTER] = @0;
//                 recent[PF_RECENT_UPDATEDACTION] = [NSDate date];
                 event[@"Recent"] = [[NSDictionary alloc ]initWithObjectsAndKeys:category,@"Category",user,PF_RECENT_USER,groupId,PF_RECENT_GROUPID,members,PF_RECENT_MEMBERS,description,PF_RECENT_DESCRIPTION,@"",PF_RECENT_LASTMESSAGE,@0,PF_RECENT_COUNTER,[NSDate date],PF_RECENT_UPDATEDACTION,[PFUser currentUser],PF_RECENT_LASTUSER, nil];
                 [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      NSLog(@"%@",event[@"Recent"]);
                      if (error != nil) NSLog(@"%@",error);
                  }];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter(NSString *groupId, NSInteger amount, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query includeKey:PF_RECENT_USER];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *recent in objects)
             {
                 if ([recent[PF_RECENT_USER] isEqualTo:[PFUser currentUser]] == NO)
                     [recent incrementKey:PF_RECENT_COUNTER byAmount:[NSNumber numberWithInteger:amount]];
                 //---------------------------------------------------------------------------------------------------------------------------------
                 recent[PF_RECENT_LASTUSER] = [PFUser currentUser];
                 recent[PF_RECENT_LASTMESSAGE] = lastMessage;
                 recent[PF_RECENT_UPDATEDACTION] = [NSDate date];
                 [recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"UpdateRecentCounter save error.");
                  }];
             }
         }
         else NSLog(@"UpdateRecentCounter query error.");
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter(NSString *groupId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *recent in objects)
             {
                 recent[PF_RECENT_COUNTER] = @0;
                 [recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"ClearRecentCounter save error.");
                  }];
             }
         }
         else NSLog(@"ClearRecentCounter query error.");
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecentItems(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:user1];
    [query whereKey:PF_RECENT_MEMBERS equalTo:user2.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *recent in objects)
             {
                 [recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"DeleteMessageItem delete error.");
                  }];
             }
         }
         else NSLog(@"DeleteMessages query error.");
     }];
}
