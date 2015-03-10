//
//  CHMainViewController.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/5.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHMainViewController.h"
#import "CHTalkingCell.h"
#import "CHTitleView.h"
#import "RelateMessage.h"
#import "ChatMessageViewController.h"

@interface CHMainViewController () <NSFetchedResultsControllerDelegate>
{
    /** 搜索结果 */
    NSFetchedResultsController *_fetchResultsController;
}
/** 标题 */
@property (nonatomic, weak) CHTitleView *titleView;
/** 最近消息列表 */
@property (nonatomic, strong) NSMutableArray *relateMsgs;

@end

@implementation CHMainViewController
#pragma mark lazy load
- (NSMutableArray *)relateMsgs
{
    if (!_relateMsgs)
    {
        _relateMsgs = [NSMutableArray array];
    }
    return _relateMsgs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // 监听一个登录状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange:) name:CHLoginStatusChangeNotification object:nil];
}

- (void)setupNav
{
    CHTitleView *titleView = [CHTitleView titleView];
    self.titleView = titleView;
    [titleView setTitle:@"微信"];
    self.navigationItem.titleView = titleView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchRequestController];
}

- (void)dealloc
{
    CHLog(@"CHMainViewController -- %s", __func__);
}

#pragma mark - 通知事件
- (void)loginStatusChange:(NSNotification *)noti{
    //通知是在子线程被调用，刷新UI在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取登录状态
        int status = [noti.userInfo[@"loginStatus"] intValue];
        
        switch (status) {
            case XMPPResultTypeConnecting://正在连接
                [self.titleView setTitle:@"正在加载..."];
                self.titleView.loading = YES;
                break;
            case XMPPResultTypeNetError://连接失败
                [self.titleView setTitle:@"连接失败，网络异常"];
                self.titleView.loading = NO;
                break;
            case XMPPResultTypeLoginSuccess://登录成功也就是连接成功
                [self.titleView setTitle:@"通信"];
                self.titleView.loading = NO;
                break;
            case XMPPResultTypeLoginFailure://登录失败
                [self.titleView setTitle:@"登录失败"];
                self.titleView.loading = NO;
                break;
            default:
                break;
        }
    });
}

#pragma mark 数据库查询
- (void)fetchRequestController
{
    NSManagedObjectContext *context = [CHCoreDataTool setupContextWithModelName:@"History"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RelateMessage"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", [UserInfo sharedUserInfo].jid];
    request.predicate = pred;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![_fetchResultsController performFetch:&error])
    {
        NSLog(@"查询数据出错 - %@", error.localizedDescription);
    }
    else
    {
        if (_fetchResultsController.fetchedObjects.count == 0) return;
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:_fetchResultsController.fetchedObjects.count];
        for (RelateMessage *relateMsg in _fetchResultsController.fetchedObjects)
        {
            [arrayM addObject:relateMsg];
        }
        self.relateMsgs = arrayM;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.relateMsgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHTalkingCell *cell = [CHTalkingCell cellViewTableView:tableView];
    
    RelateMessage *msg = self.relateMsgs[indexPath.row];
    cell.textLabel.text = msg.bareJidStr;
    cell.detailTextLabel.text = msg.timeStampStr;
    cell.imageView.image = [self loadUserImage:msg.bareJidPhoto];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RelateMessage *relateMsg = self.relateMsgs[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatMessageViewController"];
    messageVC.bareJidStr = relateMsg.bareJidStr;
    if (relateMsg.bareJidPhoto)
    {
        messageVC.bareImage = [UIImage imageWithData:relateMsg.bareJidPhoto];
    }
    NSString *myJID = [UserInfo sharedUserInfo].jid;
    NSData *myPhoto = [[[XMPPTool sharedXMPPTool]  xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:myJID]];
    messageVC.myImage = [UIImage imageWithData:myPhoto];
    [self.navigationController pushViewController:messageVC animated:YES];
}

#pragma mark - private
#pragma mark - 加载头像
- (UIImage *)loadUserImage:(NSData *)photo
{
    //没有，从用户头像模块取用户头像数据
    if (photo)
    {
        return [UIImage imageWithData:photo];
    }
    return [UIImage imageNamed:@"DefaultProfileHead"];
}

@end
