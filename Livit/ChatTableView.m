//
//  ChatTableView.m
//  Livit
//
//  Created by Nathan on 1/1/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "ChatTableView.h"
#import <MediaPlayer/MediaPlayer.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "IDMPhotoBrowser.h"
#import "RNGridMenu.h"

#import "AppConstant.h"
#import "camera.h"
#import "common.h"
#import "image.h"
#import "push.h"
#import "recent.h"
#import "video.h"
#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesComposerTextView.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"
#import "TableViewCell.h"
#import "ChatView.h"
#import "ProfileView.h"
#import "GroupSettingsView.h"

static void * kJSQMessagesKeyValueObservingContext = &kJSQMessagesKeyValueObservingContext;

@interface ChatTableView () <JSQMessagesInputToolbarDelegate,JSQMessagesKeyboardControllerDelegate, UITextViewDelegate>
{
    NSTimer *timer;
    BOOL isLoading;
    BOOL initialized;
    
    NSString *groupId;
    PFObject *event;
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    JSQMessagesAvatarImage *avatarImageBlank;
}

@end

@implementation ChatTableView


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messages.count;
}
- (id)initWith:(NSString *)groupId_

{
    self = [super init];
    groupId = groupId_;
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [messages objectAtIndex:indexPath.row];
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.nameLabel.text = message.senderDisplayName;
    cell.messageLabel.text = message.text;
    PFUser *user = [PFUser currentUser];
    PFFile *file = user[PF_USER_THUMBNAIL];
    cell.imageUser.layer.cornerRadius = cell.imageUser.frame.size.width/2;
    cell.imageUser.layer.masksToBounds = YES;
    [cell.imageUser setFile:file];
    [cell.imageUser loadInBackground];
    
    return cell;
}



- (void)viewDidLoad

{
    [super viewDidLoad];
    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user[PF_USER_FULLNAME];
  
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];

    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
 
    isLoading = NO;
    initialized = NO;
    [self loadMessages];
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = [NSBundle jsq_localizedStringForKey:@"new_message"];
    self.inputToolbar.contentView.textView.delegate = self;
    [self.view addSubview:self.inputToolbar];
    if (self.inputToolbar.contentView.textView != nil) {
        self.keyboardController = [[JSQMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView
                                                                              contextView:self.view
                                                                     panGestureRecognizer:nil delegate:self];
    }

}

- (void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    [self jsq_addObservers];
   [self.keyboardController beginListeningForKeyboard];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}


- (void)viewWillDisappear:(BOOL)animated

{
    [super viewWillDisappear:animated];
    ClearRecentCounter(groupId);
    [timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self scrollToBottomAnimated:NO];
    [self jsq_updateKeyboardTriggerPoint];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self jsq_removeObservers];
    [self.keyboardController endListeningForKeyboard];
}


- (void)jsq_updateKeyboardTriggerPoint
{
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolbar.bounds));
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        return;
    }
    
    NSInteger items = [self.tableView numberOfRowsInSection:0];
    
    if (items == 0) {
        return;
    }
    
    
    NSUInteger finalRow = MAX(0, [self.tableView numberOfRowsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionBottom;
    [self.tableView scrollToRowAtIndexPath:finalIndexPath
                                atScrollPosition:scrollPosition
                                        animated:animated];
}


#pragma mark - Messages Backend methods

- (void)loadMessages

{
    if (isLoading == NO)
    {
        isLoading = YES;
        JSQMessage *message_last = [messages lastObject];
        
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
        [query whereKey:PF_MESSAGE_GROUPID equalTo:groupId];
        if (message_last != nil) [query whereKey:PF_MESSAGE_CREATEDAT greaterThan:message_last.date];
        [query includeKey:PF_MESSAGE_USER];
        [query orderByDescending:PF_MESSAGE_CREATEDAT];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 BOOL incoming = NO;
                 //self.automaticallyScrollsToMostRecentMessage = NO;
                 for (PFObject *object in [objects reverseObjectEnumerator])
                 {
                     JSQMessage *message = [self addMessage:object];
                     if ([self incoming:message]) incoming = YES;
                 }
                 if ([objects count] != 0)
                 {
                     if (initialized && incoming)
                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                     //[self finishReceivingMessage];
                     //[self scrollToBottomAnimated:NO];
                 }
                 //self.automaticallyScrollsToMostRecentMessage = YES;
                 initialized = YES;
             }
             else [ProgressHUD showError:@"Network error."];
             isLoading = NO;
         }];
    }
}

- (JSQMessage *)addMessage:(PFObject *)object

{
    JSQMessage *message;
    PFUser *user = object[PF_MESSAGE_USER];
    NSString *name = user[PF_USER_FULLNAME];

    PFFile *fileVideo = object[PF_MESSAGE_VIDEO];
    PFFile *filePicture = object[PF_MESSAGE_PICTURE];

    if ((filePicture == nil) && (fileVideo == nil))
    {
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_MESSAGE_TEXT]];
    }

    if (fileVideo != nil)
    {
        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }

    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];

        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
                // [self.collectionView reloadData];
             }
         }];
    }

    [users addObject:user];
    [messages addObject:message];

    return message;
}



- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture

{
    PFFile *fileVideo = nil;
    PFFile *filePicture = nil;
  
    if (video != nil)
    {
        text = @"[Video message]";
        fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
    }
 
    if (picture != nil)
    {
        text = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Picture save error."];
         }];
    }
   
    PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    object[PF_MESSAGE_USER] = [PFUser currentUser];
    object[PF_MESSAGE_GROUPID] = groupId;
    object[PF_MESSAGE_TEXT] = text;
    if (fileVideo != nil) object[PF_MESSAGE_VIDEO] = fileVideo;
    if (filePicture != nil) object[PF_MESSAGE_PICTURE] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else {
             [ProgressHUD showError:@"Network error."];
             NSLog(@"error");
         }
     }];
  
    SendPushNotification(groupId, text);
    UpdateRecentCounter(groupId, 1, text);
    [self.tableView reloadData];
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = nil;
    [textView.undoManager removeAllActions];
    
    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    [self scrollToBottomAnimated:NO];

}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date

{
    [self sendMessage:text Video:nil Picture:nil];
}


- (void)didPressAccessoryButton:(UIButton *)sender

{
    [self.view endEditing:YES];
    NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"Pictures"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

#pragma mark - Input toolbar delegate

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressAccessoryButton:sender];
    }
    else {
        [self didPressSendButton:sender
                 withMessageText:self.inputToolbar.contentView.textView.text
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressSendButton:sender
                 withMessageText:self.inputToolbar.contentView.textView.text
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
    else {
        [self didPressAccessoryButton:sender];
    }
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    return messages[indexPath.item];
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = messages[indexPath.item];
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[PhotoMediaItem class]])
        {
            PhotoMediaItem *mediaItem = (PhotoMediaItem *)message.media;
            NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            [self presentViewController:browser animated:YES completion:nil];
        }
        if ([message.media isKindOfClass:[VideoMediaItem class]])
        {
            VideoMediaItem *mediaItem = (VideoMediaItem *)message.media;
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        }
    }
}


#pragma mark - RNGridMenuDelegate


- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex

{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Camera"])		PresentMultiCamera(self, YES);
    if ([item.title isEqualToString:@"Audio"])		ActionPremium(self);
    if ([item.title isEqualToString:@"Pictures"])	PresentPhotoLibrary(self, YES);
    if ([item.title isEqualToString:@"Videos"])		PresentVideoLibrary(self, YES);
    if ([item.title isEqualToString:@"Location"])	ActionPremium(self);
    if ([item.title isEqualToString:@"Stickers"])	ActionPremium(self);
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = info[UIImagePickerControllerEditedImage];

    [self sendMessage:nil Video:video Picture:picture];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (BOOL)incoming:(JSQMessage *)message
{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}


- (BOOL)outgoing:(JSQMessage *)message

{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}


#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView becomeFirstResponder];
    
    
        [self scrollToBottomAnimated:YES];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView resignFirstResponder];
}

#pragma mark - Utilities

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }
    
    [self.inputToolbar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kJSQMessagesKeyValueObservingContext];
    
    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }
    
    @try {
        [_inputToolbar.contentView.textView removeObserver:self
                                                forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                   context:kJSQMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _jsq_isObserving = NO;
}

- (void)jsq_registerForNotifications:(BOOL)registerForNotifications
{
    if (registerForNotifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_handleDidChangeStatusBarFrameNotification:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillShowNotification:)
                                                     name:UIMenuControllerWillShowMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillHideNotification:)
                                                     name:UIMenuControllerWillHideMenuNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarFrameNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillShowMenuNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillHideMenuNotification
                                                      object:nil];
    }
}




@end
