//
//  ChatViewController.h
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-19.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//





#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "JSMessagesViewController.h"
@interface ChatViewController : JSMessagesViewController<UIImagePickerControllerDelegate>{
@private

}
@property (nonatomic, strong)XMPPUserCoreDataStorageObject *Roser;

@end
