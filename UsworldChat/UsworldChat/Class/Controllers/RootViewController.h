//
//  RootViewController.h
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-14.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//
/**         ----------------- 已经解决内容如下 -------------------
 
 1.获取登陆认证
 2.好友添加认证
 3.获取好友状态
 4.解决好友未读消息提示（聊天界面不给予赋值未读，非聊天界面赋值未读消息，未读消息的增减机制）
 5.文字聊天解决
 6.语音聊天解决
 7.发送图片聊天（cell 重用问题待解决）
 8.聊天记录进行优化，获取最新的10条记录（可调整）
 9.脱机消息的处理（解决了关于中文离线消息不能接收的问题）
 10.应用的后台在线问题
 11.解决IOS自身表情发送断开连接的问题
 12.解决外网的部署问题（hostName 和 jid 后缀还是有区别的）
 13.
 **         -----------------------------------------------------
 待解决问题
 1.切换到语音模式的时候键盘不消失
 2.图片发送的cell单元格不能按照照片的比例惊醒等比例缩放，图片发送可以，但是还存在很多问题
 3.群聊的问题（较大功能模块）
 **/

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface RootViewController : UIViewController<ChatDelegate>

@end
