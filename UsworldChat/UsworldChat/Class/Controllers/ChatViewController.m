//
//  ChatViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-19.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "MessageObject.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
@interface ChatViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, ChatDelegate>{
@private
    AVAudioPlayer *_player;
}
@property (strong, nonatomic)NSMutableArray *messageArray;
@property (strong, nonatomic)NSMutableArray *timestamps;
@property (nonatomic)BOOL isdisAppear;

@end

@implementation ChatViewController
@synthesize Roser;
@synthesize isdisAppear;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.dataSource = self;
    
    self.messageArray = [NSMutableArray array];
    self.timestamps = [NSMutableArray array];
    
    self.navigationItem.title = Roser.displayName;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.isdisAppear = NO;
    
    [self getMessageCache];
    
    [self layoutSubViews:self.view.frame];
}

- (void)layoutSubViews:(CGRect)frame{
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    Roser = nil;
    self.messageArray = nil;
    self.timestamps = nil;
    self.isdisAppear = YES;
    _player = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
//    Roser = nil;
//    self.messageArray = nil;
//    self.timestamps = nil;
    self.isdisAppear = YES;
    _player = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.isdisAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- self method
- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //delegate.chatDelegate =  self;
    delegate.SecondDelegate = self;
    return delegate;
}

- (void)getCurrentMessageData:(XMPPMessage *)message{
    MessageObject *_obje = [[MessageObject alloc] init];
    [_obje setBody:message.body];
    [_obje setToStr:message.toStr];
    [self.messageArray addObject:_obje];
    
    [self.timestamps addObject:[NSDate date]];
    
    [self finishSend];
}

- (void)getMessageCache {
        NSManagedObjectContext *moc = [[[self appDelegate] xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];//
		//NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    NSArray *_LocalJidStrArr = [[[NSUserDefaults standardUserDefaults] objectForKey:kJID] componentsSeparatedByString:@"/"];
    NSString *_localJidStr = [_LocalJidStrArr objectAtIndex:0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(bareJidStr == %@ and streamBareJidStr == %@) or (bareJidStr == %@ and streamBareJidStr == %@)", Roser.jidStr, _localJidStr, _localJidStr, Roser.jidStr];
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        /*返回最大数目  top 限制可以观看历史记录的条数 每次加载以前十条记录  可以追加设置  这里的解决方案是倒序取得前十，然后再正序*/
        [fetchRequest setFetchLimit:10];
    
    NSError *error;
    NSArray *messageCache = [moc executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    messageCache = [messageCache sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd2, nil]];
        [self.messageArray removeAllObjects];
    [self initArrayFunc:messageCache];
    
}

- (void)initArrayFunc:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        MessageObject *_messageObj = [[MessageObject alloc] init];
        XMPPMessageArchiving_Message_CoreDataObject *object = [array objectAtIndex:i];
        _messageObj.body = object.body;
        _messageObj.toStr = object.message.toStr;
        [self.messageArray addObject:_messageObj];
        [self.timestamps addObject:object.timestamp];
    }
}

- (void)sendMessage:(NSString *)messageContent{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:Roser.jid];
    /* 转换汉字编码解决不能接受汉字离线消息的问题 */
    [message addBody:[messageContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[[self appDelegate] xmppStream] sendElement:message];
    [self getCurrentMessageData:message];
}

-(void)sendAudio:(NSString *)base64String withName:(NSString *)audioName{
    NSMutableString *soundString = [[NSMutableString alloc]initWithString:@"base64"];
    [soundString appendString:base64String];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:Roser.jid];
    [message addBody:soundString];
    [[[self appDelegate] xmppStream] sendElement:message];
    [self getCurrentMessageData:message];
}

-(void)sendImage:(NSString *)base64String {
    NSLog(@"Roser.jid=%@", Roser.jid);
    NSMutableString *imageStr = [[NSMutableString alloc]initWithString:@"images"];
    [imageStr appendString:base64String];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:Roser.jid];
    [message addBody:imageStr];
    [[[self appDelegate] xmppStream] sendElement:message];
    [self getCurrentMessageData:message];
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}

#pragma mark - messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text {

    [self sendMessage:text];
    [JSMessageSoundEffect playMessageSentSound];

}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //return JSBubbleMessageTypeOutgoing;
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    if ([messageObj.toStr isEqualToString:Roser.jidStr]) {
        return JSBubbleMessageTypeOutgoing;
    }else{
        return JSBubbleMessageTypeIncoming;
    }
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
   // if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]) {
      //  return JSBubbleMediaTypeText;
    //}
    //return -1;
    
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
        //return messageObj.body;
        if ([messageObj.body hasPrefix:@"images"]) {
            return JSBubbleMediaTypeImage;
        }else{
            return JSBubbleMediaTypeText;
        }
    }
    return -1;
}

- (UIButton *)sendButton {
    return [UIButton defaultSendButton];
}

-(void)cameraPressed:(id)sender {
/*打开相机*/
    NSLog(@"打开相机");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyEveryFive;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleCircle;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

- (void)VCRecordFinish:(NSString *)_filePath fileName:(NSString *)_fileName {
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:_filePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:_filePath];
        NSString *base64 = [data base64EncodedString];
        [self sendAudio:base64 withName:_fileName];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath {
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    
    UInt32 doChangeDefaultRoute = 1;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (doChangeDefaultRoute),
                             &doChangeDefaultRoute
                             );
    
    
    if ([messageObj.body hasPrefix:@"base64"]) {
        NSData *audioData = [[messageObj.body substringFromIndex:6] base64DecodedData];
        if (_player != nil) {
            _player = nil;
        }
        _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        [_player play];
        
    }
}

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
//        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
//    }
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    NSMutableString *showString = [[NSMutableString alloc] init];
    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
        //return messageObj.body;
        if ([messageObj.body hasPrefix:@"base64"]) {
            NSData *audioData = [[messageObj.body substringFromIndex:6] base64DecodedData];
            if (_player != nil) {
                _player = nil;
            }
            _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
            int timeCount = _player.duration;
            [showString appendFormat:@"点击收听 %d''", timeCount];
            for (int i = 0; i < timeCount; i++) {
                [showString appendFormat:@"%@", @" "];
            }
        }else if([messageObj.body hasPrefix:@"images"]){
            return nil;
        }else
        {
            //转码解决中文不能接受离线消息的问题
            [showString appendFormat:@"%@",[messageObj.body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        return showString;
    }
    return nil;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [NSDate date];
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessage
{
    return [UIImage imageNamed:@"demo-avatar-jobs"];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"demo-avatar-woz"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
//        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
//    }
    
    
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
        //return messageObj.body;
        if ([messageObj.body hasPrefix:@"images"]) {
            NSData *imageData = [NSData dataWithBase64EncodedString:[messageObj.body substringFromIndex:6]]; //[[messageObj.body substringFromIndex:6] base64DecodedData];
            UIImage *imageObj = [UIImage imageWithData:imageData];
            return imageObj;
        }else{
            return nil;
        }
    }
    return nil;
    
}

#pragma mark - ChatDelegate
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    //播放
    
//    UInt32 doChangeDefaultRoute = 1;
//    
//    AudioSessionSetProperty (
//                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//                             sizeof (doChangeDefaultRoute),
//                             &doChangeDefaultRoute
//                             );
//    
//    
//    if ([message.body hasPrefix:@"base64"]) {
//        NSData *audioData = [[message.body substringFromIndex:6] base64DecodedData];
//        _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
//        [_player play];
//    }
    
    //[self getMessageData];     !(message.body == NULL || [message.body isEqualToString:@""]
    if (!isdisAppear) {
        if (message.isChatMessageWithBody) {
            NSLog(@"%@ ====  %@", message.fromStr, Roser.jidStr);
            NSArray *_mesFroStrArr = [message.fromStr componentsSeparatedByString:@"/"];
            if ([[_mesFroStrArr objectAtIndex:0] isEqualToString:Roser.jidStr]) {
                [JSMessageSoundEffect playMessageReceivedSound];
                [self getCurrentMessageData:message];
            }
        }
    }
    
    
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//


#pragma mark --- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Chose image!  Details:  %@", info);
    
//    self.willSendImage = [info objectForKey:UIImagePickerControllerEditedImage];
//    [self.messageArray addObject:[NSDictionary dictionaryWithObject:self.willSendImage forKey:@"Image"]];
//    [self.timestamps addObject:[NSDate date]];
//    [self.tableView reloadData];
//    [self scrollToBottomAnimated:YES];
    
//    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0);
//    NSString *_imageDataString = [imageData base64EncodedString];
//    [self sendImage:_imageDataString];
    
	
    [self dismissViewControllerAnimated:YES completion:^{
        NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0);
        NSString *_imageDataString = [imageData base64EncodedString];
        [self sendImage:_imageDataString];
    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
