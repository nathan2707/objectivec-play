//
//  ChatTableView.h
//  Livit
//
//  Created by Nathan on 1/1/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "RNGridMenu.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesKeyboardController.h"

@interface ChatTableView : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, RNGridMenuDelegate>
- (id)initWith:(NSString *)groupId_ ;
@property (nonatomic,strong) NSString *senderId;
@property (assign, nonatomic) BOOL jsq_isObserving;
@property (nonatomic,strong) NSString *senderDisplayName;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;
@property (weak, nonatomic, readonly) JSQMessagesInputToolbar *inputToolbar;
- (void)didPressAccessoryButton:(UIButton *)sender;
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date;
@end
