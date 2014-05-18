//
//  RootViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-14.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//



#import "RootViewController.h"
#import "AppDelegate.h"
#import "FriendsViewController.h"
#import "GroupViewController.h"
@interface RootViewController ()<UITextFieldDelegate>{
@private
    UILabel *_LBLTitle;
    /* 登录按钮 */
    UIButton *_loginBtn;
    /* 注册按钮 */
    UIButton *_registerBtn;
    /* 背景点击对象 */
    UIButton *_backgroundBtn;
    /* 服务器名称 */
    UITextField *_hostTextFiled;
    /* 服务器端口号 */
    UITextField *_portTextFiled;
    /* 用户名 */
    UITextField *_userNameFiled;
    /* 密码 */
    UITextField *_passWordFiled;
    
    /* 好友 */
    UIButton *_friendsBtn;
    /* 群组 */
    UIButton *_groupsBtn;
}
- (void)loginBtnClick:(UIButton *)sender;
- (void)layoutSubViews:(CGRect)frame;
- (void)backGroundTap:(UIButton *)sender;
- (UIImage *)createImageWithColor:(UIColor *)color;
- (BOOL)allInfomationReady;
- (AppDelegate *)appDelegate;

- (void)friendsBtnClick:(UIButton *)sender;
- (void)groupsBtnClick:(UIButton *)sender;
@end

@implementation RootViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        NSLog(@"1");
//    }
//    return self;
//}

/* 通过uicolor获取uiimage */
-(UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)loginBtnClick:(UIButton *)sender {
/* 登陆Openfire系统服务器 */
   
    if (![self allInfomationReady]) {
        return;
    }
    
    [[self appDelegate] ContentFunc];
    
}

- (void)backGroundTap:(UIButton *)sender {
/* 非活动区域点击事件 */
    [_hostTextFiled resignFirstResponder];
    [_portTextFiled resignFirstResponder];
    [_userNameFiled resignFirstResponder];
    [_passWordFiled resignFirstResponder];
}

- (BOOL)allInfomationReady {
    /* 验证完整的信息 */
    if (![_hostTextFiled.text isEqual:@""] && ![_portTextFiled.text isEqual:@""] && ![_userNameFiled.text isEqual:@""] && ![_passWordFiled.text isEqual:@""]) {
        [[[self appDelegate] xmppStream] setHostName:_hostTextFiled.text];
        [[[self appDelegate] xmppStream] setHostPort:_portTextFiled.text.intValue];
        [[NSUserDefaults standardUserDefaults] setObject:_hostTextFiled.text forKey:kHostName];
        [[NSUserDefaults standardUserDefaults] setObject:_passWordFiled.text forKey:kPassword];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@@%@/UsworldChat", _userNameFiled.text, HOSTADDRESS] forKey:kJID];
        return YES;
    }
    [[self appDelegate] showAlertViewWithStr:@"信息不完整"];
    return NO;
}

- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.chatDelegate = self;
    return delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _LBLTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _LBLTitle.textColor = [UIColor grayColor];
    _LBLTitle.font = [UIFont boldSystemFontOfSize:20.0f];
    _LBLTitle.textAlignment = UITextAlignmentCenter;
    _LBLTitle.text = @"Usworld Chat";
    [self.view addSubview:_LBLTitle];
    
    _backgroundBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_backgroundBtn setTitle:@"Login" forState:UIControlStateNormal];
    [_backgroundBtn addTarget:self action:@selector(backGroundTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backgroundBtn];
    
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _loginBtn.layer.cornerRadius = 8.0f;
    [_loginBtn setBackgroundColor:[UIColor grayColor]];
    [_loginBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _registerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _registerBtn.layer.cornerRadius = 8.0f;
    [_registerBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_registerBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    [_registerBtn setTitle:@"Register" forState:UIControlStateNormal];
    //[_registerBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    
    _hostTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
    _hostTextFiled.layer.borderWidth = 1.0f;
    _hostTextFiled.layer.borderColor = [[UIColor grayColor] CGColor];
    _hostTextFiled.layer.cornerRadius = 8.0f;
    _hostTextFiled.delegate = self;
    _hostTextFiled.textColor = [UIColor grayColor];
    _hostTextFiled.placeholder = @"请填写 HostName";
    [self.view addSubview:_hostTextFiled];
    
    _portTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
    _portTextFiled.layer.borderWidth = 1.0f;
    _portTextFiled.layer.borderColor = [[UIColor grayColor] CGColor];
    _portTextFiled.layer.cornerRadius = 8.0f;
    _portTextFiled.delegate = self;
    _portTextFiled.textColor = [UIColor grayColor];
    _portTextFiled.placeholder = @"请填写服务器端口号";
    [self.view addSubview:_portTextFiled];
    
    _userNameFiled = [[UITextField alloc] initWithFrame:CGRectZero];
    _userNameFiled.layer.borderWidth = 1.0f;
    _userNameFiled.layer.borderColor = [[UIColor grayColor] CGColor];
    _userNameFiled.layer.cornerRadius = 8.0f;
    _userNameFiled.delegate = self;
    _userNameFiled.textColor = [UIColor grayColor];
    _userNameFiled.placeholder = @"请填写用户名";
    [self.view addSubview:_userNameFiled];
    
    _passWordFiled = [[UITextField alloc] initWithFrame:CGRectZero];
    _passWordFiled.layer.borderWidth = 1.0f;
    _passWordFiled.layer.borderColor = [[UIColor grayColor] CGColor];
    _passWordFiled.layer.cornerRadius = 8.0f;
    _passWordFiled.delegate = self;
    _passWordFiled.secureTextEntry = YES;
    _passWordFiled.textColor = [UIColor grayColor];
    _passWordFiled.placeholder = @"请填写密码";
    [self.view addSubview:_passWordFiled];
    
    
    
    //kuruwa-toutoumatoimac-3.local
    //shimatomacbook-pro.local
    _hostTextFiled.text = @"115.183.11.70";
    _portTextFiled.text = @"5222";
    _userNameFiled.text = @"freespaces_one";
    _passWordFiled.text = @"freespaces_one";
    
    _friendsBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _friendsBtn.layer.cornerRadius = 8.0f;
    [_friendsBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_friendsBtn setTitle:@"好友" forState:UIControlStateNormal];
    [_friendsBtn addTarget:self action:@selector(friendsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_friendsBtn];
    
    
    _groupsBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _groupsBtn.layer.cornerRadius = 8.0f;
    [_groupsBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_groupsBtn setTitle:@"群组" forState:UIControlStateNormal];
    [_groupsBtn addTarget:self action:@selector(groupsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_groupsBtn];
    
    [self layoutSubViews:self.view.frame];
}

- (void)layoutSubViews:(CGRect)frame {
    CGFloat _top = TOP;
    _backgroundBtn.frame = frame;
    _LBLTitle.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 25.0f);
    _top += SPACE_V+_LBLTitle.frame.size.height;
    _hostTextFiled.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_hostTextFiled.frame.size.height;
    _portTextFiled.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_portTextFiled.frame.size.height;
    _userNameFiled.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_userNameFiled.frame.size.height;
    _passWordFiled.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_passWordFiled.frame.size.height;
    _loginBtn.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_loginBtn.frame.size.height;
    _registerBtn.frame = CGRectMake(LEFT, _top, frame.size.width - LEFT*2, 40.0f);
    _top += SPACE_V+_registerBtn.frame.size.height;
    _friendsBtn.frame = CGRectMake(LEFT, _top, (frame.size.width - LEFT*2)/2-5.0, 40.0f);
    _groupsBtn.frame = CGRectMake(LEFT+_friendsBtn.frame.size.width+10, _top, (frame.size.width - LEFT*2)/2-5.0, 40.0f);
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    _LBLTitle = nil;
    _backgroundBtn = nil;
    _loginBtn = nil;
    _hostTextFiled = nil;
    _portTextFiled = nil;
    _userNameFiled = nil;
    _passWordFiled = nil;
    _registerBtn = nil;
    _groupsBtn = nil;
    _friendsBtn = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)friendsBtnClick:(UIButton *)sender {
    FriendsViewController *_friendCtrl = [[FriendsViewController alloc] init];
    _friendCtrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *_naviCtrl = [[UINavigationController alloc] initWithRootViewController:_friendCtrl];
    
    [self presentViewController:_naviCtrl animated:YES completion:nil];
}

- (void)groupsBtnClick:(UIButton *)sender {
    NSLog(@"进入群组页面");
    GroupViewController *_groupCtrl = [[GroupViewController alloc] init];
    _groupCtrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *_naviCtrl = [[UINavigationController alloc] initWithRootViewController:_groupCtrl];
    
    [self presentViewController:_naviCtrl animated:YES completion:nil];
}

#pragma mark - UITextFileDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self backGroundTap:nil];
    return YES;
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

#pragma mark -- CharDelegate
- (void)DidAuthenticate:(AppDelegate *)appDelegate
{
    NSLog(@"登陆界面--收到回调--登陆成功！！！！");
//    FriendsViewController *_friendCtrl = [[FriendsViewController alloc] init];
//    _friendCtrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    UINavigationController *_naviCtrl = [[UINavigationController alloc] initWithRootViewController:_friendCtrl];
//    
//    [self presentViewController:_naviCtrl animated:YES completion:nil];
}

@end
