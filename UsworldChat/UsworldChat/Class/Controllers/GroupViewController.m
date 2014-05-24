//
//  GroupViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-5-15.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "GroupViewController.h"
#import "AppDelegate.h"
#import "GroupChatViewController.h"
@interface GroupViewController ()<ChatDelegate, XMPPRoomDelegate, XMPPRoomStorage>{
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
    [_iq addAttributeWithName:__ID stringValue:@"disco2"];
    self.constID = @"disco2";
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
    NSMutableDictionary *_dic = [_groupDataList objectAtIndex:[indexPath row]];
    GroupChatViewController *_groupChatCtrl = [[GroupChatViewController alloc] init];
    _groupChatCtrl.groupDic = _dic;
    [self.navigationController pushViewController:_groupChatCtrl animated:YES];
    
    //加入房间
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:FROM stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:kJID]];
    //房间名字 服务器名字 进入房间后使用的昵称
    [presence addAttributeWithName:TO stringValue:[NSString stringWithFormat:@"%@/%@", [_dic objectForKey:@"jid"], UserName]];
    [[self appDelegate].xmppStream sendElement:presence];
    
//    //进入房间说话
//    NSString *_tostr = [_dic objectForKey:@"jid"];
//    XMPPJID *_jid = [XMPPJID jidWithString:_tostr];
//    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:_jid];
//    /* 转换汉字编码解决不能接受汉字离线消息的问题 */
//    [message addBody:[@"hello world!" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[[self appDelegate] xmppStream] sendElement:message];
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPRoomStorage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
// -- PUBLIC METHODS --
//
// There are no public methods required by this protocol.
//
// Each individual storage class will provide a proper way to access/enumerate the
// occupants/messages according to the underlying storage mechanism.
//


//
//
// -- PRIVATE METHODS --
//
// These methods are designed to be used ONLY by the XMPPRoom class.
//
//

/**
 * Configures the storage class, passing it's parent and parent's dispatch queue.
 *
 * This method is called by the init method of the XMPPRoom class.
 * This method is designed to inform the storage class of it's parent
 * and of the dispatch queue the parent will be operating on.
 *
 * A storage class may choose to operate on the same queue as it's parent,
 * as the majority of the time it will be getting called by the parent.
 * If both are operating on the same queue, the combination may run faster.
 *
 * Some storage classes support multiple xmppStreams,
 * and may choose to operate on their own internal queue.
 *
 * This method should return YES if it was configured properly.
 * It should return NO only if configuration failed.
 * For example, a storage class designed to be used only with a single xmppStream is being added to a second stream.
 * The XMPPCapabilites class is configured to ignore the passed
 * storage class in it's init method if this method returns NO.
 **/
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue{
    return YES;
}

/**
 * Updates and returns the occupant for the given presence element.
 * If the presence type is "available", and the occupant doesn't already exist, then one should be created.
 **/
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room{
NSLog(@"1");
}

/**
 * Stores or otherwise handles the given message element.
 **/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
NSLog(@"2");
}
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
NSLog(@"3");
}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
 **/
- (void)handleDidLeaveRoom:(XMPPRoom *)room{
NSLog(@"4");
}

/**
 * May be used if there's anything special to do when joining a room.
 **/
- (void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname{
NSLog(@"5");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPRoomDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
NSLog(@"6");
}

/**
 * Invoked with the results of a request to fetch the configuration form.
 * The given config form will look something like:
 *
 * <x xmlns='jabber:x:data' type='form'>
 *   <title>Configuration for MUC Room</title>
 *   <field type='hidden'
 *           var='FORM_TYPE'>
 *     <value>http://jabber.org/protocol/muc#roomconfig</value>
 *   </field>
 *   <field label='Natural-Language Room Name'
 *           type='text-single'
 *            var='muc#roomconfig_roomname'/>
 *   <field label='Enable Public Logging?'
 *           type='boolean'
 *            var='muc#roomconfig_enablelogging'>
 *     <value>0</value>
 *   </field>
 *   ...
 * </x>
 *
 * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
 *
 * @see fetchConfigurationForm:
 * @see configureRoomUsingOptions:
 **/
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
NSLog(@"7");
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm{
NSLog(@"8");
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
NSLog(@"9");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
NSLog(@"11");
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
NSLog(@"12");
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
NSLog(@"13");
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{
NSLog(@"14");
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
NSLog(@"15");
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
NSLog(@"16");
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
NSLog(@"17");
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
NSLog(@"18");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{
NSLog(@"19");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{
NSLog(@"21");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
NSLog(@"31");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"41");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
NSLog(@"51");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
NSLog(@"61");
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult{
NSLog(@"71");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError{
    NSLog(@"81");
}


@end
