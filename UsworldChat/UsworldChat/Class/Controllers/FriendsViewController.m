//
//  FriendsViewController.m
//  UsworldChat
//
//  Created by 郭 涛涛 on 14-3-17.
//  Copyright (c) 2014年 ifreespaces. All rights reserved.
//

#import "FriendsViewController.h"
#import "DDLog.h"
#import "ChatViewController.h"
@interface FriendsViewController (){
    NSMutableArray *dataList;
    UIBarButtonItem *_addBI;
    UIBarButtonItem *_offBI;
    UIAlertView *_addFrame;
    UIAlertView *_offLineFrame;
    NSString *_currentJID;
}
@property (nonatomic, strong)NSMutableArray *dataList;
- (void)layoutSubViews:(CGRect)frame;
//- (void)getData;
- (AppDelegate *)appDelegate;
- (void)viewUnDidLoad;
@end

@implementation FriendsViewController
@synthesize tableViewList;
@synthesize dataList;

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
    self.title = @"Friends";
    
    //[self fetchContacts];
    self.dataList = [[NSMutableArray alloc] init];
    _currentJID = [[NSString alloc] init];
    //[self getData];
    
    tableViewList = [[UITableView alloc] initWithFrame:CGRectZero];
    tableViewList.delegate = self;
    tableViewList.dataSource = self;
    [self.view addSubview:tableViewList];
    
    _addBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend:)];
    self.navigationItem.rightBarButtonItem = _addBI;
    
    _offBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(offLineFunc:)];
    self.navigationItem.leftBarButtonItem = _offBI;
    
    
    [self layoutSubViews:self.view.frame];
}

- (void)viewDidAppear:(BOOL)animated {
    _currentJID = nil;
}

#pragma mark -- self method
- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.chatDelegate =  self;
    return delegate;
}

- (void)offLineFunc:(id)sender {
    _offLineFrame = [[UIAlertView alloc] initWithTitle:@"退出登陆" message:@"您确定要退出登陆吗？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    _offLineFrame.tag = 101;
    [_offLineFrame show];
}

- (void)addFriend:(id)sender {
    //NSLog(@"+ FRIENDS");
    //[[[self appDelegate] xmppRoster] addUser:[XMPPJID jidWithString:@"看牙宝客服@saas.kanyabao.com"] withNickname:@"看牙宝客服"];
    _addFrame = [[UIAlertView alloc] initWithTitle:@"Add Friends" message:@"输入用户名和昵称" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
    _addFrame.tag = 100;
    _addFrame.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *userNameTF = (UITextField *)[_addFrame textFieldAtIndex:0];
    UITextField *niceNameTF = (UITextField *)[_addFrame textFieldAtIndex:1];
    userNameTF.placeholder = @"用户名";
    niceNameTF.placeholder = @"昵  称";
    niceNameTF.secureTextEntry = NO;
    [_addFrame show];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
        NSManagedObjectContext *moc = [[[self appDelegate] xmppRosterCoreDataStorage] mainThreadManagedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"sectionNum" cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        NSError *error = nil;
        
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error.localizedDescription);
		}
        //NSLog(@"[fetchedResultsController.sections count] = %lu", (unsigned long)[fetchedResultsController.sections count]);
    }
    
    
    return fetchedResultsController;
}

- (void)layoutSubViews:(CGRect)frame
{
    tableViewList.frame = CGRectMake(0.0f, 0.0, frame.size.width, frame.size.height);
}

- (void)viewUnDidLoad {
    //[super viewDidUnload];
    tableViewList = nil;
    dataList = nil;
    fetchedResultsController = nil;
    _addBI = nil;
    _offBI = nil;
    _addFrame = nil;
    _offLineFrame = nil;
    _currentJID = nil;
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

#pragma mark -- NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    fetchedResultsController = nil;
    [tableViewList reloadData];
}

#pragma mark -- UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%d", [indexPath row]);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([user.unreadMessages intValue] != 0) {
        /* 未读书目清零 */
        user.unreadMessages = [NSNumber numberWithInt:0];
    }
    /* 设置实时聊天JID */
    _currentJID = user.displayName;
    ChatViewController *chatViewCtrl = [[ChatViewController alloc] init];
    chatViewCtrl.Roser = user;
    [self.navigationController pushViewController:chatViewCtrl animated:YES];
}

#pragma mark -- UItableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *sections = [[self fetchedResultsController] sections];
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
        int sectionNum = [sectionInfo.name intValue];
        switch (sectionNum) {
            case 0:
            {
                return @"Available";
                break;
            }
                case 1:
            {
                return @"Away";
                break;
            }
                
            default:{
            return @"Offline";
                break;
            }
        }
        
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return [self.dataList count];
    NSArray *sections = [[self fetchedResultsController] sections];
	
	if (section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //NSLog(@"%d, %d", [user.sectionNum intValue], indexPath.section);
    //    声明静态字符串型对象，用来标记重用单元格
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
        UILabel *_lblbadgeView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
        _lblbadgeView.tag = 1212;
        _lblbadgeView.center = CGPointMake(20.0, 11.0);
        _lblbadgeView.clipsToBounds = YES;
        _lblbadgeView.backgroundColor = [UIColor redColor];
        _lblbadgeView.layer.cornerRadius = 7.0f;
        _lblbadgeView.layer.borderWidth = 2.0f;
        _lblbadgeView.layer.borderColor = [[UIColor grayColor] CGColor];
        _lblbadgeView.textColor = [UIColor whiteColor];
        _lblbadgeView.font = [UIFont boldSystemFontOfSize:15.0];
        _lblbadgeView.textAlignment = UITextAlignmentCenter;
        _lblbadgeView.hidden = YES;
        [cell.contentView addSubview:_lblbadgeView];
    }
    // Configure the cell...
    //NSLog(@"----------%d", [indexPath row]);
    cell.textLabel.text = user.displayName;
    //cell.detailTextLabel.text = @"";
    
    for (UILabel *lblTag in cell.contentView.subviews) {
        if (lblTag.tag == 1212) {
            //[lblTag removeFromSuperview];
            if ([user.unreadMessages intValue] > 0) {
                lblTag.hidden = NO;
                lblTag.text = [NSString stringWithFormat:@"%d", [user.unreadMessages intValue]];
            }else{
                lblTag.hidden = YES;
            }
        }
    }
    
    
    
    return cell;
}

#pragma mark -- UIAlterViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            UITextField *userNameTF = (UITextField *)[alertView textFieldAtIndex:0];
            UITextField *niceNameTF = (UITextField *)[alertView textFieldAtIndex:1];
            if (![userNameTF.text isEqual:@""] && ![userNameTF.text isEqual:nil]) {
                XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", userNameTF.text, [[NSUserDefaults standardUserDefaults] objectForKey:kHostName]]];
                NSString *nickName = [niceNameTF.text isEqual:nil]?@"":niceNameTF.text;
                [[[self appDelegate] xmppRoster] addUser:jid withNickname:nickName];
            }else {
                [[self appDelegate] showAlertViewWithStr:@"用户名必须填写"];
            }
            
        }
    }else if (alertView.tag == 101){
        if (buttonIndex == 1) {
            //[[self appDelegate] disconnect];
            [self dismissViewControllerAnimated:YES completion:^{
                [[self appDelegate] DisconnectFunc];
            }];
        }
    }
}

#pragma mark -- CharDelegate
- (void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message {

    XMPPUserCoreDataStorageObject *user = [[self appDelegate].xmppRosterCoreDataStorage userForJID:[message from]
                                                                     xmppStream:[self appDelegate].xmppStream
                                                           managedObjectContext:[[self appDelegate].xmppRosterCoreDataStorage mainThreadManagedObjectContext]];
    
    if (![_currentJID isEqualToString:user.displayName]) {
        /* 对于正在实时聊天界面的不给予未读消息增加 */
        user.unreadMessages = [NSNumber numberWithInt:[user.unreadMessages intValue]+1];
    }
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
