//
//  GroupViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-5-15.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "GroupViewController.h"
#import "AppDelegate.h"
@interface GroupViewController ()<ChatDelegate>{
@private
    UIBarButtonItem *_backBI;
    NSArray *_groupDataList;
}
@property(nonatomic, strong)NSString * constID;
- (void)viewUnDidLoad;
- (AppDelegate *)appDelegate;
/*
 *获取房间列表
 */
- (void)getGroupData;
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
    
    [self getGroupData];
    
    //填充当前的TableView
    
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

#pragma self Func
- (void)viewUnDidLoad{
    _groupListView = nil;
    _backBI = nil;
    _groupListView = nil;
}

- (AppDelegate *)appDelegate {
    AppDelegate *_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _delegate.groupsDelegate = self;
    return _delegate;
}

- (void)getGroupData {
    NSXMLElement *_iq = [NSXMLElement elementWithName:@"iq"];
    [_iq addAttributeWithName:FROM stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:kJID]];
    [_iq addAttributeWithName:__ID stringValue:@"disco1"];
    self.constID = @"disco1";
    [_iq addAttributeWithName:TO stringValue:[NSString stringWithFormat:@"conference.%@", HOSTADDRESS]];
    [_iq addAttributeWithName:TYPE stringValue:@"get"];
    
    NSXMLElement *_query = [NSXMLElement elementWithName:@"query"];
    [_query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [_iq addChild:_query];
    
    [[[self appDelegate] xmppStream] sendElement:_iq];
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
#pragma charDelegate
- (void)getIQ:(AppDelegate *)appD IQ:(XMPPIQ *)iq {
    NSLog(@"----------------------IQ=%@", iq.attributesAsDictionary);
    NSMutableDictionary *_attributeDic = iq.attributesAsDictionary;
    if ([[_attributeDic objectForKey:__ID] isEqualToString:self.constID]) {
        NSLog(@"ID验证正确，获取房间列表数据");
        
    }
    
}


@end
