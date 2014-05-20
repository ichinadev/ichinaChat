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
    NSMutableArray *_groupDataList;
}
@property(nonatomic, strong)NSString * constID;
- (void)viewUnDidLoad;
- (AppDelegate *)appDelegate;
- (void)layoutSubViews:(CGRect)frame;
/*
 *获取房间列表
 */
- (void)getGroupData;
@end

@implementation GroupViewController
@synthesize constID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _groupDataList = [[NSMutableArray alloc] init];
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
    _groupListView = [[UITableView alloc] initWithFrame:CGRectZero];
    _groupListView.delegate = self;
    _groupListView.dataSource = self;
    [self.view addSubview:_groupListView];
    
    [self layoutSubViews:self.view.frame];
}

- (void)layoutSubViews:(CGRect)frame {
    _groupListView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
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
        NSLog(@"ID验证正确，获取房间列表数据%ld,%@", iq.childElement.childCount, iq.childElement.children);
        for (int i = 0; i < iq.childElement.childCount; i++) {
            NSXMLElement *item = (NSXMLElement *)[iq.childElement.children objectAtIndex:i];
            NSMutableDictionary *_groupDic = item.attributesAsDictionary;
            if (![_groupDataList containsObject:_groupDic]) {
                [_groupDataList addObject:_groupDic];
            }
        }
    [_groupListView reloadData];
    }
}


#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupDataList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // didselect event
    
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:FROM stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:kJID]];
    //房间名字 服务器名字 进入房间后使用的昵称
    NSMutableDictionary *_dic = [_groupDataList objectAtIndex:[indexPath row]];
    [presence addAttributeWithName:TO stringValue:[NSString stringWithFormat:@"%@/%@", [_dic objectForKey:@"jid"], UserName]];
    [[self appDelegate].xmppStream sendElement:presence];
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
//        UILabel *_lblbadgeView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
//        _lblbadgeView.tag = 1212;
//        _lblbadgeView.center = CGPointMake(20.0, 11.0);
//        _lblbadgeView.clipsToBounds = YES;
//        _lblbadgeView.backgroundColor = [UIColor redColor];
//        _lblbadgeView.layer.cornerRadius = 7.0f;
//        _lblbadgeView.layer.borderWidth = 2.0f;
//        _lblbadgeView.layer.borderColor = [[UIColor grayColor] CGColor];
//        _lblbadgeView.textColor = [UIColor whiteColor];
//        _lblbadgeView.font = [UIFont boldSystemFontOfSize:15.0];
//        _lblbadgeView.textAlignment = UITextAlignmentCenter;
//        _lblbadgeView.hidden = YES;
//        [cell.contentView addSubview:_lblbadgeView];
    }
    // Configure the cell...
    //NSLog(@"----------%d", [indexPath row]);
    NSMutableDictionary *_dic = [_groupDataList objectAtIndex:[indexPath row]];
    cell.textLabel.text = [_dic objectForKey:@"name"];
    //cell.detailTextLabel.text = @"";
    
//    for (UILabel *lblTag in cell.contentView.subviews) {
//        if (lblTag.tag == 1212) {
//            //[lblTag removeFromSuperview];
//            if ([user.unreadMessages intValue] > 0) {
//                lblTag.hidden = NO;
//                lblTag.text = [NSString stringWithFormat:@"%d", [user.unreadMessages intValue]];
//            }else{
//                lblTag.hidden = YES;
//            }
//        }
//    }
    
    
    
    return cell;
}

@end
