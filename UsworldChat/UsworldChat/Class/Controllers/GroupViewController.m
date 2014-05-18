//
//  GroupViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-5-15.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "GroupViewController.h"

@interface GroupViewController (){
@private
    UIBarButtonItem *_backBI;
}
- (void)viewUnDidLoad;
@end

@implementation GroupViewController

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
    self.title = @"Groups";
    self.view.backgroundColor = [UIColor cyanColor];
    _backBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backFunc:)];
    self.navigationItem.leftBarButtonItem = _backBI;
}

- (void)backFunc:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewUnDidLoad{
    _groupListView = nil;
    _backBI = nil;
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
