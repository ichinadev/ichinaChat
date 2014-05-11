//
//  FriendsViewController.h
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-17.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface FriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ChatDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>{
@private
    UITableView *tableViewList;
    NSFetchedResultsController *fetchedResultsController;
}
@property (nonatomic, strong)UITableView *tableViewList;

@end
