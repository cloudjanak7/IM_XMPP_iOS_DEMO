//
//  ChatMessageViewController.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/19.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "ChatMessageViewController.h"
#import <CoreData/CoreData.h>
#import "ChatMessageCell.h"
#import "RecorderTool.h"
#import "CHMessageFrame.h"
#import "MessageObject.h"
#import "SoundTool.h"
#import "CHBackButton.h"
#import "CHTitleView.h"
#import "RelateMessage.h"


@interface ChatMessageViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    //查询结果控制器
    NSFetchedResultsController *_fetchedResultsController;
    /** 播放器 */
    AVAudioPlayer *_player;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noInputTextConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *inputText;

/** 消息列表 */
@property (nonatomic, strong) NSMutableArray *messageList;

- (IBAction)clickAddPhoto;

//开始录音
- (IBAction)clickRecord;
//发送录音
- (IBAction)sendRecord;
//取消发送
- (IBAction)cancelRecord;
// 播放录音
- (IBAction)playRecord:(UIButton *)btn;

@end

@implementation ChatMessageViewController
#pragma mark - lazy load
- (NSMutableArray *)messageList
{
    if (!_messageList)
    {
        _messageList = [NSMutableArray array];
    }
    return _messageList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNav];
    
    //1.利用通知中心监听键盘的变化（打开、关闭、中英文切换）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //2.初始化查询结果控制器
    [self setupFetchedResultsController];
}

- (void)setupNav
{
    CHBackButton *btn = [CHBackButton backButton];
    btn.frame = CGRectMake(0, 10, 100, 44);
    [btn setTitle:@"名册" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    CHTitleView *titleView = [CHTitleView titleView];
    [titleView setTitle:_bareJidStr];
    self.navigationItem.titleView = titleView;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ChatBackgroundThumb_00.jpg"]];
}

#pragma mark 回退，最近消息列表装载
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];

    CHMessageFrame *msgF = [self.messageList lastObject];

    if (!msgF.msgObj.timeStamp)
    {
        return;
    }
    // 上下文
    NSManagedObjectContext *context = [CHCoreDataTool setupContextWithModelName:@"History"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RelateMessage"];
    // 是否数据库有相应消息对象
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@", _bareJidStr, [UserInfo sharedUserInfo].jid];
    request.predicate = pre;
    RelateMessage *relateMsg = [[context executeFetchRequest:request error:nil] lastObject];
    if (relateMsg == nil)
    {
        relateMsg = [NSEntityDescription insertNewObjectForEntityForName:@"RelateMessage" inManagedObjectContext:context];
    }
    
    relateMsg.bareJidStr = _bareJidStr;
    if (_bareImage)
    {
        relateMsg.bareJidPhoto = UIImagePNGRepresentation(_bareImage);
    }
    
    
    relateMsg.timestamp = msgF.msgObj.timeStamp;
    NSString *body = nil;
    switch (msgF.msgObj.messageType)
    {
        case MessageTypeImage:
            body = @"[图像]";
            break;
        case MessageTypeRecord:
            body = @"[录音]";
            break;
        case MessageTypeText:
            body = msgF.msgObj.messageText;
            break;
        default:
            break;
    }
    relateMsg.body = body;

    relateMsg.streamBareJidStr = [UserInfo sharedUserInfo].jid;
    
    NSError *error = nil;
    [context save:&error];
    if (error)
    {
        NSLog(@"error -- %@", error.localizedDescription);
    }
}

#pragma mark - 初始化查询结果控制器
- (void)setupFetchedResultsController
{
    if (self.messageList.count == 0)
    {
        //1.context
        NSManagedObjectContext *context = [[[XMPPTool sharedXMPPTool] xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
        //2.定义查询请求
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
        //3.定义排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        [request setSortDescriptors:@[sort]];
        //4.定义查询条件（谓词），查询来自
        request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@", _bareJidStr, [UserInfo sharedUserInfo].jid];
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
            NSMutableArray *arrayM = [NSMutableArray array];
            
            for (XMPPMessageArchiving_Message_CoreDataObject *message in _fetchedResultsController.fetchedObjects)
            {
                CHMessageFrame *msgF = [CHMessageFrame messageFrameWithXMPPMessage:message];
                [arrayM addObject:msgF];
            }
            self.messageList = arrayM;
            [self scrollToTableBottom];
        }
    }
}

#pragma mark - NSFetchedResultsController Delegate
#pragma mark 数据库查询到新的消息
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        CHMessageFrame *msgF = [CHMessageFrame messageFrameWithXMPPMessage:(XMPPMessageArchiving_Message_CoreDataObject *)anObject];
        [self.messageList addObject:msgF];

        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:(self.messageList.count - 1) inSection:0];

        [self.tableView insertRowsAtIndexPaths:@[rowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:rowIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [self.tableView deselectRowAtIndexPath:rowIndexPath animated:NO];
    }
}

#pragma mark - 键盘边框大小变化
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    //1.获取目标区域
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //2.根据rect的orgin.y可以判断键盘是否开启还是关闭
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height)
    {
        _noInputTextConstraint.constant = 0;
    }
    //2.根据目标位置的高度判断键盘类型
    else
    {
        //打开键盘
        _noInputTextConstraint.constant = rect.size.height;
    }
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self scrollToTableBottom];
    }];
    
}

#pragma mark - UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //发送消息
    //1.取出文本并截断空白字符串
    NSString *str = [textField.text trimString];
    MessageObject *msgObj = [[MessageObject alloc] init];
    msgObj.messageType = MessageTypeText;
    msgObj.messageText = str;
    [self sendMessage:msgObj];
    return YES;
}

#pragma mark - UITableView DataSource
#pragma mark 表格行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHMessageFrame *msgF = self.messageList[indexPath.row];
    
    ChatMessageCell *cell = [ChatMessageCell cellForTableView:tableView withMessageFrame:msgF myImage:self.myImage bareImage:self.bareImage];
    
    return cell;
}

#pragma mark 表格行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //提示：在此不能直接调用表格行控件的高度，否则会死循环
    //1.取出显示文本
    CHMessageFrame *msgF = self.messageList[indexPath.row];
    
    return msgF.cellHeight;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ***************点击按钮响应
#pragma mark 播放录音
- (IBAction)playRecord:(UIButton *)btn
{
    ChatMessageCell *cell = (ChatMessageCell *)btn.superview.superview;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CHMessageFrame *msgF = self.messageList[indexPath.row];
    if (msgF.msgObj.messageType == MessageTypeRecord) {
#warning 问题
        NSData *data = [[NSData alloc] initWithBase64EncodedString:msgF.msgObj.fileDataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        _player = [SoundTool audioPlayerWithData:data];
        //循环播放次数
        [_player setNumberOfLoops:0];
        //预先缓存，提高声音播放的流畅性
        [_player prepareToPlay];
        [_player play];
    }

    CHLog(@"%f,\n %f,\n %@,\n %@,\n %@", btn.contentEdgeInsets.right, btn.contentEdgeInsets.left, NSStringFromCGRect(btn.titleLabel.frame), NSStringFromCGRect(btn.frame), NSStringFromCGRect(btn.imageView.frame));
}

#pragma mark 点击添加照片按钮
- (void)clickAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        NSLog(@"摄像头不可用");
    }
}

#pragma mark 开始录音
- (IBAction)clickRecord
{
    RecorderTool *record = [RecorderTool sharedRecorderTool];
    
    NSDate * recordDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *recordName = [NSString stringWithFormat:@"%@_%@.caf", [UserInfo sharedUserInfo].user,[dateformatter stringFromDate:recordDate]];
    [record createRecorderName:recordName];
    
    if ([record isRecording])
    {
        [[RecorderTool sharedRecorderTool] stopRecording];
    } else {
        [[RecorderTool sharedRecorderTool] startRecording];
    }
    CHLog(@"begin record");
}

#pragma mark 发送录音
- (IBAction)sendRecord
{
    RecorderTool *record = [RecorderTool sharedRecorderTool];
    if (![record isRecording])
    {
        return;
    }
    [record stopRecording];
    NSData *recordData = [NSData dataWithContentsOfFile:record.urlPath];
    MessageObject *msgObj = [[MessageObject alloc] init];
    msgObj.fileDataStr = [recordData xmpp_base64Encoded];
    msgObj.fileName = [record.urlPath lastPathComponent];
    msgObj.fileSize = [recordData length];
    msgObj.recordTime = record.currentTime;
    msgObj.messageType = MessageTypeRecord;
    [self sendMessage:msgObj];
}

#pragma mark 取消发送
- (IBAction)cancelRecord
{
    
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSString *imageType = info[UIImagePickerControllerMediaType];

    [self dismissViewControllerAnimated:YES completion:^{
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        MessageObject *msgObj = [[MessageObject alloc] init];
        msgObj.fileDataStr = [data xmpp_base64Encoded];
        msgObj.fileName = imageType;
        msgObj.fileSize = [data length];
        msgObj.recordTime = 0;
        msgObj.messageType = MessageTypeImage;
        [self sendMessage:msgObj];
    }];
}

#pragma mark - private
#pragma mark 滚动表格末尾
- (void)scrollToTableBottom
{
    if (self.messageList.count == 0) return;
    //1.根据行数实例化indexPath
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.messageList.count - 1) inSection:0];
    //2.选中并滚动到末尾
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 发送消息
- (void)sendMessage:(MessageObject *)msgObj
{
    NSDictionary *dict = [msgObj toDictionary];
    
    NSString *value = @"";
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:_bareJidStr]];
    [message addChild:[DDXMLNode elementWithName:@"body" stringValue:value]];
    [[XMPPTool sharedXMPPTool].xmppStream sendElement:message];
}

@end
