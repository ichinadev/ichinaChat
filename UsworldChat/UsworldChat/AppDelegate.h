//
//  AppDelegate.h
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-14.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//  测试变更

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "CustomWindow.h"
@protocol ChatDelegate;
@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate, XMPPReconnectDelegate, XMPPRosterDelegate, UIAlertViewDelegate>{
@private
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchiving;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<ChatDelegate> chatDelegate;
@property (strong, nonatomic) id SecondDelegate;
@property (strong, nonatomic) id groupsDelegate;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
@property (strong, nonatomic) XMPPRoster *xmppRoster;
@property (strong, nonatomic) XMPPMessageArchiving *xmppMessageArchiving;
@property (strong, nonatomic) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

- (BOOL)ContentFunc;
- (void)DisconnectFunc;
- (void)showAlertViewWithStr:(NSString *)str;
@end

@protocol ChatDelegate <NSObject>
@optional
- (void)DidAuthenticate:(AppDelegate *)appDelegate;
- (void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message;

- (void)getIQ:(AppDelegate *)appD IQ:(XMPPIQ *)iq;
@end