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
@interface GroupChatViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, ChatDelegate>{

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
- (void)viewUnDidLoad{
    self.messageArray = nil;
    self.timestamps = nil;
    self.groupDic = nil;
}
#pragma mark -- self method
- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //delegate.chatDelegate =  self;
    //delegate.SecondDelegate = self;
    return delegate;
}

- (void)sendMessage:(NSString *)messageContent {
   
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
    //MessageObject *messageObj = (MessageObject *)[self.messageArray objectAtIndex:indexPath.row];
    //if ([messageObj.toStr isEqualToString:Roser.jidStr]) {
        return JSBubbleMessageTypeOutgoing;
   // }else{
    //    return JSBubbleMessageTypeIncoming;
   // }
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

@end
