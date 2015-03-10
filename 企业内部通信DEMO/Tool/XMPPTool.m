//
//  XMPPTool.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "XMPPTool.h"
#import "XMPP.h"

NSString *const CHLoginStatusChangeNotification = @"CHLoginStatusNotification";

@interface XMPPTool ()<XMPPStreamDelegate, XMPPRosterDelegate,TURNSocketDelegate>
{
    /** 自动连接模块 */
    XMPPReconnect *_xmppReconnect;
    /** 电子名片存储 */
    XMPPvCardCoreDataStorage *_xmppvCardStorage;
    /** 聊天模块 */
    XMPPMessageArchiving *_xmppMessageArchiving;
    /** 实体扩展模块 */
    XMPPCapabilities *_xmppCapabilities;
    /** 数据存储 */
    XMPPCapabilitiesCoreDataStorage *_xmppCapabilitiesCoreDataStorage;
}
//传输文件数组
@property (nonatomic, strong) NSMutableArray *socketList;
/** 返回结果block */
@property (nonatomic, copy) void (^XMPPResultBlock)(XMPPResultType type);

/** 初始化XMPPStream */
- (void)setupXMPPStream;
/** 连接到服务器[传一个JID] */
- (void)connectToHost;
/** 发送授权密码 */
- (void)sendPwdToHost;
/** 发送"在线"消息 */
- (void)sendOnlineToHost;

@end

@implementation XMPPTool
singleton_implementation(XMPPTool)

- (void)dealloc
{
    //释放XMPP相关对象扩展模块
    [self teardownStream];
}

#pragma mark - private
#pragma mark 初始化XMPPStream
- (void)setupXMPPStream
{
    //0.方法调用时，要求_xmppstream必须为nil，否则通过断言提示程序员，并终止程序运行
    NSAssert(_xmppStream == nil, @"XMPPStream被多次实例化");
    //1.实例化XMPPStream
    _xmppStream = [[XMPPStream alloc] init];
    
    //让XMPP在真机运行时支持后台，在模拟器上市不支持后台服务运行的
    if (TARGET_IPHONE_SIMULATOR)
    {
        [_xmppStream setEnableBackgroundingOnSocket:YES];
    }
    
    
    //2.扩展模块
    //2.1重新连接模块
    _xmppReconnect = [[XMPPReconnect alloc] init];
    //2.2电子名片模块
    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardModule];
    //2.4花名册模块
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    //设置自动连接接收好友订阅请求
    [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:YES];
    //自动从服务器更新好友记录，例如好友自己更改的名片
    [_xmppRoster setAutoFetchRoster:YES];
    
    //2.5实体扩展模块
    _xmppCapabilitiesCoreDataStorage = [[XMPPCapabilitiesCoreDataStorage alloc] init];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesCoreDataStorage];
    
    //2.6消息归档模块
    _xmppMessageArchivingCoreDataStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
    
    //3.将重新连接模块添加到XMPPStream
    [_xmppReconnect activate:_xmppStream];
    [_xmppvCardModule activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppCapabilities activate:_xmppStream];
    [_xmppMessageArchiving activate:_xmppStream];
    
    //支持后台运行
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    //4.添加代理
    //由于所有网络请求都是做基于网络的数据处理，这些数据处理工作于界面UI无关
    //因此可以让代理方法在其他线程中运行，从而提高程序的运行性能，避免出现应用程序阻塞的情况
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark 销毁XMPPStream并注销已注册的扩展模块
- (void)teardownStream
{
    //删除代理
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    //取消激活在setupXMPPStream方法中的扩展模块
    [_xmppReconnect deactivate];
    [_xmppvCardModule deactivate];
    [_xmppvCardAvatarModule deactivate];
    [_xmppRoster deactivate];
    [_xmppCapabilities deactivate];
    [_xmppMessageArchiving deactivate];
    //断开XMPPStream的连接
    [_xmppStream disconnect];
    
    
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppvCardModule = nil;
    _xmppvCardStorage = nil;
    _xmppvCardAvatarModule = nil;
    _xmppMessageArchiving = nil;
    _xmppRosterStorage = nil;
    _xmppCapabilities = nil;
    _xmppRoster = nil;
}

#pragma mark 发送授权密码
- (void)sendPwdToHost
{
    CHLog(@"发送密码授权");
    
    NSString *pwd = [UserInfo sharedUserInfo].pwd;
    
    NSError *error;
    if (![_xmppStream authenticateWithPassword:pwd error:&error]) {
        if (error)
        {
            CHLog(@"密码错误:%@",error.localizedDescription);
        }
    }
}

#pragma mark 通知服务器用户上线
- (void)sendOnlineToHost
{
    CHLog(@"发送在线消息");
    XMPPPresence *presence = [XMPPPresence presence];
    
    [_xmppStream sendElement:presence];
}

#pragma mark 连接到服务器[传一个JID]
- (void)connectToHost
{
    CHLog(@"开始连接服务器");
    if (!_xmppStream)
    {
        [self setupXMPPStream];
    }
    
    // 发送通知【正在连接】
    [self postNotification:XMPPResultTypeConnecting];
    
#warning 手动睡眠2秒

    NSString *user = nil;
    if (self.isRegisterOperation)
    {
        user = [UserInfo sharedUserInfo].registerUser;
    }
    else
    {
        user = [UserInfo sharedUserInfo].user;
    }
    
    NSString *hostName = [UserInfo sharedUserInfo].hostName;
    
    //设置JID
    _xmppStream.myJID = [XMPPJID jidWithUser:user domain:XMPPDomain resource:@"iPhone"];
    
    //设置服务器域名
    _xmppStream.hostName = hostName;
    //设置服务器端口
    _xmppStream.hostPort = 5222;
    
    //连接
    NSError *error;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        CHLog(@"error:%@", error.debugDescription);
    }

}

#pragma mark 判断IQ是否为SI请求
- (BOOL)isSIRequest:(XMPPIQ *)iq
{
    NSXMLElement *si = [iq elementForName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    NSString *uuid = [[si attributeForName:@"id"] stringValue];
    if (si && uuid)
    {
        return YES;
    }
    return NO;
}

#pragma mark 推送通知
- (void)postNotification:(XMPPResultType)resultType{
    
    // 将登录状态放入字典，然后通过通知传递
    NSDictionary *userInfo = @{@"loginStatus":@(resultType)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHLoginStatusChangeNotification object:nil userInfo:userInfo];
}

#pragma mark - public
#pragma mark 注销
/** 注销 */
- (void)xmppUserLogout
{
    //1.发送离线消息
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    
    //2.断开连接
    [_xmppStream disconnect];
    
    //3.回到登录界面
    [UIStoryboard showInitialVCWithName:@"Login"];
    
    [UserInfo sharedUserInfo].loginStatus = NO;
    [[UserInfo sharedUserInfo] saveUserInfoToSandbox];
}

#pragma mark 注册
/** 注册 */
- (void)xmppUserRegister:(void (^)(XMPPResultType))result
{
    self.XMPPResultBlock = result;
    [_xmppStream disconnect];
    [self connectToHost];
}
     
/** 登录 */
- (void)xmppUserLogin:(void (^)(XMPPResultType))result
{
    self.XMPPResultBlock = result;
        
    //如果连接过服务器，要断开
    [_xmppStream disconnect];
        
    [self connectToHost];
}
     
     

#pragma mark - 代理方法
#pragma mark 与主机连接成功(如果服务器地址不对，就不会调用此方法)
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    CHLog(@"与主机连接成功");
    if (self.isRegisterOperation)
    {
        NSString *pwd = [UserInfo sharedUserInfo].registerPwd;
        [_xmppStream registerWithPassword:pwd error:nil];
    }
    else
    {
        [self sendPwdToHost];
    }
}

#pragma mark 与主机连接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    CHLog(@"与主机断开连接");
    
    if (error && _XMPPResultBlock)
    {
        CHLog(@"与主机连接失败:%@", error.localizedDescription);
        _XMPPResultBlock(XMPPResultTypeNetError);
    }
    if (error) {
        //通知 【网络不稳定】
        [self postNotification:XMPPResultTypeNetError];
    }
}

#pragma mark 授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    CHLog(@"授权成功");
    
    if (_XMPPResultBlock)
    {
        _XMPPResultBlock(XMPPResultTypeLoginSuccess);
    }
    
    [self postNotification:XMPPResultTypeLoginSuccess];
    
    [self sendOnlineToHost];
}

#pragma mark 密码错误身份验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    CHLog(@"授权失败:%@", error);
    
    if (_XMPPResultBlock)
    {
        _XMPPResultBlock(XMPPResultTypeLoginFailure);
    }
    
    [self postNotification:XMPPResultTypeLoginFailure];
}

#pragma mark 注册失败(用户名已经存在)
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    CHLog(@"注册失败%@", error.description);
    self.XMPPResultBlock(XMPPResultTypeRegisterFailure);
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    CHLog(@"注册成功");
    if (self.XMPPResultBlock)
    {
        self.XMPPResultBlock(XMPPResultTypeRegisterSuccess);
    }
}

#pragma mark 用户展现变化
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //NSLog(@"接收到用户展现数据 -- %@", presence);
    //1.判断接收到的presence类型是否为subscribe
    if ([presence.type isEqualToString:@"subscribe"])
    {
        //1.1取出presence中的from的jid并添加好友
        XMPPJID *from = [presence from];
        //1.2接收来自from的订阅请求
        [_xmppRoster acceptPresenceSubscriptionRequestFrom:from andAddToRoster:YES];
    }
}

#pragma mark 接收请求
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //NSLog(@"接收到请求 %@",iq);
    //0.判断IQ是否为SI请求
    if ([self isSIRequest:iq])
    {
        TURNSocket *socket = [[TURNSocket alloc] initWithStream:_xmppStream toJID:iq.to];
        [_socketList addObject:socket];
        [socket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    //1.判断iq的类型是否为新的文件传输请求
    else if ([TURNSocket isNewStartTURNRequest:iq])
    {
        //实例化socket
        TURNSocket *socket = [[TURNSocket alloc] initWithStream:sender incomingTURNRequest:iq];
        //使用一个数组记录住所有传输文件所用的socket
        [_socketList addObject:socket];
        //添加代理
        [socket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return YES;
}

#pragma mark 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        // 本地通知
        UILocalNotification *localNoti = [[UILocalNotification alloc] init];
        
        // 设置内容
        localNoti.alertBody = [NSString stringWithFormat:@"一条来自%@的消息", message.fromStr];
        // 设置通知时间
        localNoti.fireDate = [NSDate date];
        // 声音
        localNoti.soundName = @"default";
        
        // 执行
        [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    }
    
}

#pragma mark - XMPPRoster代理
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //NSLog(@"接收其他用户的请求:%@",presence);
}

#pragma mark - TURNSocket Delegate
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    //NSLog(@"成功");
    //保存或者发送文件
    //写数据方法，向其他客户端发送文件
    //    [socket writeData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>];
    //读数据方法，接收来自其他客户端的文件
    //    [socket readDataToData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
    //完成时断开
}

- (void)turnSocketDidFail:(TURNSocket *)sender
{
    //NSLog(@"失败");
}

@end
