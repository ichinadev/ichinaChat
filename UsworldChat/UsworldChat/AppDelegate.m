//
//  AppDelegate.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-14.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "FriendsViewController.h"
#import "NSString+Base64.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate(){
@private
    AVAudioPlayer *_player;
}
- (void)startStreamFunc;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
@end

@implementation AppDelegate
@synthesize window;
@synthesize xmppReconnect;
@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRosterCoreDataStorage;
@synthesize chatDelegate;
@synthesize xmppMessageArchiving;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize SecondDelegate;
@synthesize groupsDelegate;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    RootViewController *_rootViewCtrl = [[RootViewController alloc] init];
    self.window.rootViewController = _rootViewCtrl;
    [self.window makeKeyAndVisible];
    /* 初始化 XMPP 相关 */
    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:kJID];
    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:kPassword];
    [self startStreamFunc];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
#if TARGET_IPHONE_SIMULATOR
	//DDLogError(@"The iPhone simulator does not process background network traffic. "
			   //@"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			NSLog(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -- self method
- (void)showAlertViewWithStr:(NSString *)str{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Usworld Chat" message:str delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark -- XMPP 
- (void)startStreamFunc{
    xmppStream = [[XMPPStream alloc] init];
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:self.xmppStream];
    
    xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterCoreDataStorage];
    [xmppRoster activate:self.xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchiving setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchiving activate:xmppStream];
    [xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
    [xmppMessageArchiving removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
    [xmppMessageArchiving  deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterCoreDataStorage = nil;
    xmppMessageArchiving = nil;
    xmppMessageArchivingCoreDataStorage = nil;
}

/* 连接openFire */
- (BOOL)ContentFunc {
    NSString *_jid = [[NSUserDefaults standardUserDefaults] objectForKey:kJID];
    NSString *_pw = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
    if (_jid == nil || _pw == nil) {
        return NO;
    }
    
    XMPPJID *_xmppjid = [XMPPJID jidWithString:_jid];
    NSError *_error;
    [xmppStream setMyJID:_xmppjid];
    //这里设置服务器地址  jid后面一定要跟服务器的机器的名字  目前发现的问题  如果不写验证不过去
    [xmppStream setHostName:[[NSUserDefaults standardUserDefaults] objectForKey:kHostName]];
    if (![xmppStream connectWithTimeout:30 error:&_error]) {
        [self showAlertViewWithStr:_error.localizedDescription];
    }
    return YES;
}

- (void)DisconnectFunc
{
	//[self goOffline];
	[xmppStream disconnect];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)dealloc {
    [self teardownStream];
}

#pragma mark - XMPPStreamDelegate
/* 将要进行连接 */
- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    NSLog(@"xmppStreamWillConnect");
}

/* 可以开始和服务器安全的通信 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidConnect");
    NSString *_pw = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
    if (_pw) {
        NSError *error;
        if (![self.xmppStream authenticateWithPassword:_pw error:&error]) {
            [self showAlertViewWithStr:error.debugDescription];
        }else {
            [self showAlertViewWithStr:@"登陆成功"];
            if ([self.chatDelegate respondsToSelector:@selector(DidAuthenticate:)]) {
                [self.chatDelegate DidAuthenticate:self];
            }
        }
    }
}
/* 成功完成验证 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidAuthenticate");

    [self goOnline];
}
/* 未成功完成验证 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"didNotAuthenticate%@", error.description);
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
    NSLog(@"didSendIQ %@", iq.description);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error{
    NSLog(@"didFailToSendIQ %@", iq.description);
    [self showAlertViewWithStr:error.localizedDescription];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"didReceiveIQ %@", iq.description);

    if ([self.groupsDelegate respondsToSelector:@selector(getIQ:IQ:)]) {
        [self.groupsDelegate getIQ:self IQ:iq];
    }
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    NSLog(@"didSendPresence:%@",presence.description);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    NSLog(@"didFailToSendPresence:%@",error.description);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"didReceivePresence: %@",presence.description);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"didReceiveError: %@",error.description);
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"xmppStreamConnectDidTimeout");
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWasToldToDisconnect");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect: %@",error.description);
    if ([error.description isEqual:nil]) {
        [self showAlertViewWithStr:@"退出成功"];
    }else {
        //[self showAlertViewWithStr:error.localizedDescription];
    }
}

- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
    NSLog(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return @"UsworldChat";
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    NSLog(@"socketDidConnect %@", socket.localHost);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    NSLog(@"didReceiveMessage%@", message.description);
    
    if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterCoreDataStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[[self xmppRosterCoreDataStorage] mainThreadManagedObjectContext]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                                message:body
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//			[alertView show];
		}
		else
		{
            NSMutableString *showString = [[NSMutableString alloc] init];
            if ([message.body hasPrefix:@"base64"]) {
                NSData *audioData = [[message.body substringFromIndex:6] base64DecodedData];
                if (_player != nil) {
                    _player = nil;
                }
                _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
                int timeCount = _player.duration;
                [showString appendFormat:@"点击收听 %d''", timeCount];
                for (int i = 0; i < timeCount; i++) {
                    [showString appendFormat:@"%@", @" "];
                }
            }else if ([message.body hasPrefix:@"images"]){
                [showString appendString:@"发来图片"];
            }else{
                [showString appendFormat:@"%@",[message.body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
            localNotification.soundName = UILocalNotificationDefaultSoundName;
			localNotification.alertBody = [NSString stringWithFormat:@"%@:%@",displayName,showString];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
        
        if ([self.chatDelegate respondsToSelector:@selector(getNewMessage:Message:)]) {
            [self.chatDelegate getNewMessage:self Message:message];
        }
        
        if ([self.SecondDelegate respondsToSelector:@selector(getNewMessage:Message:)]) {
            [self.SecondDelegate getNewMessage:self Message:message];
        }
	}
}


#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}

#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"didReceivePresenceSubscriptionRequest--%@", presence.description);
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:@"add" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"yes", @"yes and add too", nil];
    alertView.tag = 1000;
    [alertView show];
}

- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item{
    NSLog(@"didRecieveRosterItem--%@", item.description);
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"xmppRosterDidBeginPopulating--%@", sender.description);
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"xmppRosterDidEndPopulating--%@", sender.description);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
    if (alertView.tag == 1000)
    {
//        if (buttonIndex == 1) {
//        /* 同意添加 */
//        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
//         /* 带昵称添加好友 */
//        //[[self xmppRoster] addUser:jid withNickname:<#(NSString *)#>];
//    }else {
//        /* 拒绝添加 */
//        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:jid] ;
//    }
        switch (buttonIndex) {
            case 2:
            {
                /* 同意添加并且添加对方 */
                [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
                break;}
            case 1:
            {
                /* 同意添加 */
                [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:NO];
                break;
            }
                
            default:
            {
                /* 拒绝添加 */
                [self.xmppRoster rejectPresenceSubscriptionRequestFrom:jid] ;
                break;
            }
        }
    }
}




@end
