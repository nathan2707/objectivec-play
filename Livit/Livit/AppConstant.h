//
//  AppConstant.h
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define		DEFAULT_TAB							0
#define		VIDEO_LENGTH						5

#define		COLOR_OUTGOING                      HEXCOLOR(0x007AFFFF)

#define		COLOR_INCOMING						HEXCOLOR(0xE6E5EAFF)

#define		SCREEN_WIDTH						[UIScreen mainScreen].bounds.size.width
#define		SCREEN_HEIGHT						[UIScreen mainScreen].bounds.size.height


#define		PREMIUM_LINK						@"Available soon"

#define		MESSAGE_INVITE						@"Check out Ocur on the App Store"


#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_TWITTERID					@"twitterId"			//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
#define     PF_USER_RADIUS                      @"distancePreference"   //  Integer
#define     PF_USER_AGE_PREFERENCE              @"agePreference"        //  Integer
#define     PF_USER_WOMEN_ON                    @"womenPreference"      //  Bool
#define     PF_USER_MEN_ON                      @"menPreference"        //  Bool
#define     PF_USER_GENDER                      @"gender"               // String
#define     PF_USER_AGE                         @"age"                  // Integer
#define     PF_USER_CATEGORY1                   @"category1"            // String
#define     PF_USER_CATEGORY2                   @"category2"            // String
#define     PF_USER_CATEGORY3                   @"category3"            // String
#define     PF_USER_DESCRIPTION                 @"description"          // String
#define     PF_USER_POSITION                    @"geolocalisation"      //  Dictionary of coordinates
#define     PF_USER_BIRTHDAY                    @"birthday"             // Date
#define     PF_USER_LAST_ACTION                 @"lastAction"           // Date
#define     PF_USER_POINT                       @"Geopoint"             // Geopoint
//-----------------------------------------------------------------------
#define		PF_BLOCKED_CLASS_NAME				@"Blocked"				//	Class name
#define		PF_BLOCKED_USER						@"user"					//	Pointer to User Class
#define		PF_BLOCKED_USER1					@"user1"				//	Pointer to User Class
#define		PF_BLOCKED_USER2					@"user2"				//	Pointer to User Class
#define		PF_BLOCKED_USERID2					@"userId2"				//	String
//-----------------------------------------------------------------------
#define		PF_GROUP_CLASS_NAME					@"Group"				//	Class name
#define		PF_GROUP_USER						@"user"					//	Pointer to User Class
#define		PF_GROUP_NAME						@"name"					//	String
#define		PF_GROUP_MEMBERS					@"members"				//	Array
//-----------------------------------------------------------------------
#define		PF_MESSAGE_CLASS_NAME				@"Message"				//	Class name
#define		PF_MESSAGE_USER						@"user"					//	Pointer to User Class
#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
#define		PF_MESSAGE_TEXT						@"text"					//	String
#define		PF_MESSAGE_PICTURE					@"picture"				//	File
#define		PF_MESSAGE_VIDEO					@"video"				//	File
#define		PF_MESSAGE_CREATEDAT				@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_PEOPLE_CLASS_NAME				@"People"				//	Class name
#define		PF_PEOPLE_USER1						@"user1"				//	Pointer to User Class
#define		PF_PEOPLE_USER2						@"user2"				//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_RECENT_CLASS_NAME				@"Recent"				//	Class name
#define		PF_RECENT_USER						@"user"					//	Pointer to User Class
#define		PF_RECENT_GROUPID					@"groupId"				//	String
#define		PF_RECENT_MEMBERS					@"members"				//	Array
#define		PF_RECENT_DESCRIPTION				@"description"			//	String
#define		PF_RECENT_LASTUSER					@"lastUser"				//	Pointer to User Class
#define		PF_RECENT_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_RECENT_COUNTER					@"counter"				//	Number
#define		PF_RECENT_UPDATEDACTION				@"updatedAction"		//	Date
//-----------------------------------------------------------------------
#define		PF_REPORT_CLASS_NAME				@"Report"				//	Class name
#define		PF_REPORT_USER1						@"user1"				//	Pointer to User Class
#define		PF_REPORT_USER2						@"user2"				//	Pointer to User Class
//--------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
