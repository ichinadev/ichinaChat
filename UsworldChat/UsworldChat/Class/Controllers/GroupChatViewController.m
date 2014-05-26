//
//  GroupChatViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-5-21.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "GroupChatViewController.h"
#import "AppDelegate.h"
#import "NSString+Base64.h"
#import "MessageObject.h"
@interface GroupChatViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource,XMPPRoomDelegate, XMPPRoomStorage>{
@private
    XMPPRoom *_room;
    UIBarButtonItem *_backBI;
}
@property (strong, nonatomic)NSMutableArray *messageArray;
@property (strong, nonatomic)NSMutableArray *timestamps;
- (void)viewUnDidLoad;
- (AppDelegate *)appDelegate;
@end

@implementation GroupChatViewController
@synthesize groupDic;
@synthesize messageArray;
@synthesize timestamps;

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
    self.title = [self.groupDic objectForKey:@"name"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.delegate = self;
    self.dataSource = self;
    
    self.messageArray = [NSMutableArray array];
    self.timestamps = [NSMutableArray array];
    
    _backBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backFun:)];
    self.navigationItem.leftBarButtonItem = _backBI;
    
    XMPPJID* jid=[XMPPJID jidWithString:[self.groupDic objectForKey:@"jid"]];
    _room=[[XMPPRoom alloc] initWithRoomStorage:self jid:jid];
    [_room activate:[self appDelegate].xmppStream];
    [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_room joinRoomUsingNickname:UserName history:nil];
}

- (void)backFun:(id)sender {
    [_room leaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil)
    { self.view = nil; // 需要开发者手动释放控制器的视图。
        [self viewUnDidLoad]; // 视图已被卸载，调用viewDIdLoad的反操作。
    }
}

- (void)dealloc{
    if ([self isViewLoaded]) {
        [self viewUnDidLoad];
    }
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

#pragma self Func
-(UIImage *)imageFromText:(NSString *)text{
    UIFont *_font = [UIFont systemFontOfSize:50.0];
    UIColor *_color;
    if ([text isEqualToString:@"system"]) {
        _color = [UIColor brownColor];
    }else{
        _color = [UIColor yellowColor];
    }
    NSDictionary *attribute = @{NSFontAttributeName:_font, NSBackgroundColorAttributeName:[UIColor grayColor], NSForegroundColorAttributeName:_color};
    CGSize textsize = [text sizeWithAttributes:attribute];
    UIGraphicsBeginImageContext(textsize);
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    // optional: add a shadow
    // optional: also, to avoid clipping you should make the context size bigger
    //CGContextSetShadowWithColor(ctx, CGSizeMake(2.0, -2.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:attribute];
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;  
}

- (void)viewUnDidLoad{
    self.messageArray = nil;
    self.timestamps = nil;
    self.groupDic = nil;
    _room = nil;
    _backBI = nil;
}
#pragma mark -- self method
- (NSDate *)UsWorldDateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //delegate.chatDelegate =  self;
    //delegate.SecondDelegate = self;
    return delegate;
}

- (void)sendMessage:(NSString *)messageContent {
 //   XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:[groupDic objectForKey:@"jid"]];
    /* 转换汉字编码解决不能接受汉字离线消息的问题 */
 //   [message addBody:[messageContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[[self appDelegate] xmppStream] sendElement:message];
//    [self getCurrentMessageData:message];
    [_room sendMessageWithBody:[messageContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - tableViewDataSource
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
    if ([messageObj.fromStr isEqualToString:UserName]) {
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
    
//    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
//    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
//        //return messageObj.body;
//        if ([messageObj.body hasPrefix:@"images"]) {
//            return JSBubbleMediaTypeImage;
//        }else{
            return JSBubbleMediaTypeText;
//        }
//    }
//    return -1;
}

- (UIButton *)sendButton {
    return [UIButton defaultSendButton];
}

-(void)cameraPressed:(id)sender {
    /*打开相机*/
//    NSLog(@"打开相机");
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:picker animated:YES completion:NULL];
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
    return JSMessagesViewTimestampPolicyCustom;
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
//    NSFileManager *fileManager = [[NSFileManager alloc]init];
//    if ([fileManager fileExistsAtPath:_filePath]) {
//        
//        NSData *data = [NSData dataWithContentsOfFile:_filePath];
//        NSString *base64 = [data base64EncodedString];
//        [self sendAudio:base64 withName:_fileName];
//    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath {
//    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
//    
//    UInt32 doChangeDefaultRoute = 1;
//    
//    AudioSessionSetProperty (
//                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//                             sizeof (doChangeDefaultRoute),
//                             &doChangeDefaultRoute
//                             );
//    
//    
//    if ([messageObj.body hasPrefix:@"base64"]) {
//        NSData *audioData = [[messageObj.body substringFromIndex:6] base64DecodedData];
//        if (_player != nil) {
//            _player = nil;
//        }
//        _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
//        [_player play];
//        
//    }
}

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
    //        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
    //    }
//    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
//    NSMutableString *showString = [[NSMutableString alloc] init];
//    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
//        //return messageObj.body;
//        if ([messageObj.body hasPrefix:@"base64"]) {
//            NSData *audioData = [[messageObj.body substringFromIndex:6] base64DecodedData];
//            if (_player != nil) {
//                _player = nil;
//            }
//            _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
//            int timeCount = _player.duration;
//            [showString appendFormat:@"点击收听 %d''", timeCount];
//            for (int i = 0; i < timeCount; i++) {
//                [showString appendFormat:@"%@", @" "];
//            }
//        }else if([messageObj.body hasPrefix:@"images"]){
//            return nil;
//        }else
//        {
//            //转码解决中文不能接受离线消息的问题
//            [showString appendFormat:@"%@",[messageObj.body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        }
//        return showString;
//    }
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    NSMutableString *showString = [[NSMutableString alloc] init];
    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
        //转码解决中文不能接受离线消息的问题
                    [showString appendFormat:@"%@",[messageObj.body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return showString;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [NSDate date];
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessageAtIndexPath:(NSIndexPath *)indexPath
{
    //return [UIImage imageNamed:@"demo-avatar-jobs"];
    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    if (messageObj.fromStr == nil) {
        return [self imageFromText:@"system"];
    }else {
        return [self imageFromText:messageObj.fromStr];
    }
}

- (UIImage *)avatarImageForOutgoingMessageAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIImage imageNamed:@"demo-avatar-woz"];
    //return [self imageFromText:@"我"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
    //        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    //    }
    
    
//    MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
//    if (![messageObj.body isEqual:nil] && ![messageObj.body isEqual:@""]) {
//        //return messageObj.body;
//        if ([messageObj.body hasPrefix:@"images"]) {
//            NSData *imageData = [NSData dataWithBase64EncodedString:[messageObj.body substringFromIndex:6]]; //[[messageObj.body substringFromIndex:6] base64DecodedData];
//            UIImage *imageObj = [UIImage imageWithData:imageData];
//            return imageObj;
//        }else{
//            return nil;
//        }
//    }
    return nil;
    
}

#pragma mark - ChatDelegate
//-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
//{
//    //播放
//    
//    //    UInt32 doChangeDefaultRoute = 1;
//    //
//    //    AudioSessionSetProperty (
//    //                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//    //                             sizeof (doChangeDefaultRoute),
//    //                             &doChangeDefaultRoute
//    //                             );
//    //
//    //
//    //    if ([message.body hasPrefix:@"base64"]) {
//    //        NSData *audioData = [[message.body substringFromIndex:6] base64DecodedData];
//    //        _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
//    //        [_player play];
//    //    }
//    
//    //[self getMessageData];     !(message.body == NULL || [message.body isEqualToString:@""]
////    if (!isdisAppear) {
////        if (message.isChatMessageWithBody) {
//            NSLog(@"%@ ====  %@", message.fromStr, [self.groupDic objectForKey:@"jid"]);
////            NSArray *_mesFroStrArr = [message.fromStr componentsSeparatedByString:@"/"];
////            if ([[_mesFroStrArr objectAtIndex:0] isEqualToString:Roser.jidStr]) {
////                [JSMessageSoundEffect playMessageReceivedSound];
////                [self getCurrentMessageData:message];
////            }
////        }
////    }
//
//    
//}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPRoomStorage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
// -- PUBLIC METHODS --
//
// There are no public methods required by this protocol.
//
// Each individual storage class will provide a proper way to access/enumerate the
// occupants/messages according to the underlying storage mechanism.
//


//
//
// -- PRIVATE METHODS --
//
// These methods are designed to be used ONLY by the XMPPRoom class.
//
//

/**
 * Configures the storage class, passing it's parent and parent's dispatch queue.
 *
 * This method is called by the init method of the XMPPRoom class.
 * This method is designed to inform the storage class of it's parent
 * and of the dispatch queue the parent will be operating on.
 *
 * A storage class may choose to operate on the same queue as it's parent,
 * as the majority of the time it will be getting called by the parent.
 * If both are operating on the same queue, the combination may run faster.
 *
 * Some storage classes support multiple xmppStreams,
 * and may choose to operate on their own internal queue.
 *
 * This method should return YES if it was configured properly.
 * It should return NO only if configuration failed.
 * For example, a storage class designed to be used only with a single xmppStream is being added to a second stream.
 * The XMPPCapabilites class is configured to ignore the passed
 * storage class in it's init method if this method returns NO.
 **/
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue{
    return YES;
}

/**
 * Updates and returns the occupant for the given presence element.
 * If the presence type is "available", and the occupant doesn't already exist, then one should be created.
 **/
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room{
    NSLog(@"1 handlePresence");
}

/**
 * Stores or otherwise handles the given message element.
 **/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    //NSLog(@"2");
    NSLog(@"handleIncomingMessage %@", message.body);
}
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    NSLog(@"3");
}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
 **/
- (void)handleDidLeaveRoom:(XMPPRoom *)room{
    NSLog(@"4 handleDidLeaveRoom");
}

/**
 * May be used if there's anything special to do when joining a room.
 **/
- (void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname{
    NSLog(@"5 handleDidJoinRoom withNickname %@", nickname);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPRoomDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"6");
}

/**
 * Invoked with the results of a request to fetch the configuration form.
 * The given config form will look something like:
 *
 * <x xmlns='jabber:x:data' type='form'>
 *   <title>Configuration for MUC Room</title>
 *   <field type='hidden'
 *           var='FORM_TYPE'>
 *     <value>http://jabber.org/protocol/muc#roomconfig</value>
 *   </field>
 *   <field label='Natural-Language Room Name'
 *           type='text-single'
 *            var='muc#roomconfig_roomname'/>
 *   <field label='Enable Public Logging?'
 *           type='boolean'
 *            var='muc#roomconfig_enablelogging'>
 *     <value>0</value>
 *   </field>
 *   ...
 * </x>
 *
 * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
 *
 * @see fetchConfigurationForm:
 * @see configureRoomUsingOptions:
 **/
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    NSLog(@"7");
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm{
    NSLog(@"8");
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    NSLog(@"9");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    NSLog(@"11");
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidJoin");
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"13  xmppRoomDidLeave");
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{
    NSLog(@"14");
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"15 occupantDidJoin %@ withPresence %@", occupantJID.resource, presence.type);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"16 occupantDidLeave %@ withPresence %@", occupantJID.resource, presence.type);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"17 occupantDidUpdate %@ withPresence %@", occupantJID.resource, presence.type);
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    //NSLog(@"18");
    NSMutableDictionary *messageDic;// = ((NSXMLElement *)[message.children objectAtIndex:2]).attributesAsDictionary;
    NSLog(@"didReceiveMessage %@ from %@", message.body, occupantJID.resource);
    
    MessageObject *_obje = [[MessageObject alloc] init];
    [_obje setBody:message.body];
    [_obje setToStr:message.toStr];
    [_obje setFromStr:occupantJID.resource];
    [self.messageArray addObject:_obje];
    
    //获取消息的时间
    for (int i = 0; i < message.childCount; i++) {
        NSXMLElement *xmlelement = [message.children objectAtIndex:i];
        if ([xmlelement.xmlns isEqualToString:@"urn:xmpp:delay"]) {
            messageDic = xmlelement.attributesAsDictionary;
        }
    }
    NSLog(@"该消息的时间为%@", [messageDic objectForKey:@"stamp"]);
    NSLog(@"该消息的时间nsdate为%@", [self UsWorldDateFromString:[messageDic objectForKey:@"stamp"]]);
    NSDate *_DATE = [self UsWorldDateFromString:[messageDic objectForKey:@"stamp"]];
    if (_DATE == nil) {
       [self.timestamps addObject:[NSDate date]];
    }else {
       [self.timestamps addObject:[self UsWorldDateFromString:[messageDic objectForKey:@"stamp"]]];
    }
    
    [self finishSend];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{
    NSLog(@"19");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{
    NSLog(@"21");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"31");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"41");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"51");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    NSLog(@"61");
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult{
    NSLog(@"71");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError{
    NSLog(@"81");
}

@end
