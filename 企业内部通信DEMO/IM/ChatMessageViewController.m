//
//  ChatMessageViewController.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/19.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "ChatMessageViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface ChatMessageViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    //查询结果控制器
    NSFetchedResultsController *_fetchedResultsController;
}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *noInputTextConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *englishConstraint;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //1.利用通知中心监听键盘的变化（打开、关闭、中英文切换）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //2.初始化查询结果控制器
    [self setupFetchedResultsController];
}

#pragma mark - 初始化查询结果控制器
- (void)setupFetchedResultsController
{
    //1.context
    NSManagedObjectContext *context = [[xmppDelegate xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
    //2.定义查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //3.定义排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sort]];
    //4.定义查询条件（谓词），查询来自
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = 'guo@127.0.0.1' AND streamBareJidStr = 'sun@127.0.0.1'"];
    //5.实例化查询结果控制器
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    //6.设置代理
    _fetchedResultsController.delegate = self;
    //7.执行查询
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"查询数据出错 - %@", error.localizedDescription);
    }
    else
    {
        [self scrollToTableBottom];
    }
}

#pragma mark - NSFetchedResultsController Delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //刷新表格
    [self.tableView reloadData];
    //滚动到表格末尾
    [self scrollToTableBottom];
}

#pragma mark - 键盘边框大小变化
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    NSLog(@"%@",notification.userInfo);
    //userInfo的UIKeyboardFrameEndUserInfoKey可以判断键盘大小和目标位置
    //1.获取目标区域
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //2.根据rect的orgin.y可以判断键盘是否开启还是关闭
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height)
    {
        NSArray *array = [self.view constraints];
        if (![array containsObject:self.noInputTextConstraint])
        {
            [self.view addConstraint:self.noInputTextConstraint];
        }
    }
    //2.根据目标位置的高度判断键盘类型
    else if(rect.size.height == 216)
    {
        //英文键盘
        [self.view removeConstraint:self.noInputTextConstraint];
        NSArray *array = [self.view constraints];
        if (![array containsObject:self.englishConstraint])
        {
            [self.view addConstraint:self.englishConstraint];
        }
        
    }
    else if (rect.size.height == 252)
    {
        //中文键盘
        [self.view removeConstraint:self.noInputTextConstraint];
        [self.view removeConstraint:self.englishConstraint];
    }
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    [self scrollToTableBottom];
}

#pragma mark - UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    //发送消息
    //1.取出文本并截断空白字符串
    NSString *str = [textField.text trimString];
    //2.实例化XMPPMessage
    NSString *jidStr = @"guo@127.0.0.1";
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:jidStr]];
    [message addBody:str];
    [[xmppDelegate xmppStream] sendElement:message];
    textField.text = @"";
    return YES;
}

#pragma mark - 表格操作方法
#pragma mark 滚动表格末尾
- (void)scrollToTableBottom
{
    //选中滚动到最末一条记录
    //1.知道所有的记录行数
    id<NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[0];
    NSInteger count = [info numberOfObjects];
    //2.根据行数实例化indexPath
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
    //3.选中并滚动到末尾
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark - UITableView DataSource
#pragma mark 表格行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[section];
    return [info numberOfObjects];
}

#pragma mark 表格行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromID = @"ChatFromCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FromID forIndexPath:indexPath];
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.body;
    return cell;
}

@end
