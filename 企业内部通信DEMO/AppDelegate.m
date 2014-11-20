//
//  AppDelegate.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-9-28.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginUser.h"
#import "NSString+Helper.h"

#define kNotificationUserLogonState @"NotificationUserLogon"
@interface AppDelegate () <XMPPStreamDelegate, XMPPRosterDelegate>
{
    XMPPReconnect *_xmppReconnect;//xmpp重新连接XMPPStream
    completionBlock _completionBlock;
    completionBlock _faildBlock;
    
    XMPPvCardCoreDataStorage *_xmppvCardStorage;//电子名片的数据存储模块
    
    XMPPCapabilities *_xmppCapabilities;//实体扩展模块
    XMPPCapabilitiesCoreDataStorage *_xmppCapabilitiesCoreDataStorage;//数据存储
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self setupStream];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connect];
}

- (void)dealloc
{
    //释放XMPP相关对象扩展模块
    [self teardownStream];
}

//设置XMPPStream
- (void)setupStream
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
    
    //4.添加代理
    //由于所有网络请求都是做基于网络的数据处理，这些数据处理工作于界面UI无关
    //因此可以让代理方法在其他线程中运行，从而提高程序的运行性能，避免出现应用程序阻塞的情况
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
//销毁XMPPStream并注销已注册的扩展模块
- (void)teardownStream
{
    //删除代理
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    //取消激活在setupStream方法中的扩展模块
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
//通知服务器用户上线
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    //发送presence给服务器
    [_xmppStream sendElement:presence];
}
//连接到服务器
- (void)connect
{
    //如果XMPPStream当前已经连接，直接返回
    if ([_xmppStream isConnected]) return;
    //指定用户名、密码、主机（服务器）
    NSString *hostName = [[LoginUser sharedLoginUser] hostName];
    NSString *userName = [[LoginUser sharedLoginUser] myJIDName];
    NSString *password = [[LoginUser sharedLoginUser] password];
    
    if ([hostName isEmptyString] || [userName isEmptyString] || [password isEmptyString])
    {
        [self showStroyboardWithLogonState:NO];
        return;
    }
    
    //设置XMPPStream的JID和主机
    [_xmppStream setMyJID:[XMPPJID jidWithString:userName]];
    [_xmppStream setHostName:hostName];
    
    //开始连接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    //如果没有指定JID和hostname才会出错，其他都不出错
    if (error)
    {
        NSLog(@"连接出错 -- %@",error.localizedDescription);
    }
    else
    {
        NSLog(@"连接请求发送成功");
    }
}
//通知服务器用户下线
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}
//与服务器断开连接
- (void)disConnect
{
    [self goOffline];
    [_xmppStream disconnect];
}

- (void)logout
{
    //通知服务器下线并断开连接
    [self disConnect];

    [self showStroyboardWithLogonState:NO];
}
#pragma mark - 代理方法
#pragma mark 连接完成(如果服务器地址不对，就不会调用此方法)
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接建立");
    NSString *password = [[LoginUser sharedLoginUser] password];
    NSError *error = nil;
    if (_isRgisterUser)
    {
        [_xmppStream registerWithPassword:password error:&error];
    }
    else
    {
        [_xmppStream authenticateWithPassword:password error:&error];
    }
}

#pragma mark 连接到服务器
- (void)connectWithcompletion:(completionBlock)completion failed:(completionBlock)faild
{
    //记录块代码
    _completionBlock = completion;
    _faildBlock = faild;
    if ([_xmppStream isConnected]) {
        [self disConnect];
    }
    //连接到服务器
    [self connect];
}

#pragma mark 验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self showStroyboardWithLogonState:YES];
    if (_completionBlock != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _completionBlock();
        });
    }
    
    [self goOnline];
}

#pragma mark 密码错误身份验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"currentThread --- %@", [NSThread currentThread]);
    if (_faildBlock != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock();
        });
    }
    [self showStroyboardWithLogonState:NO];
}

#pragma mark 注册失败(用户名已经存在)
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    _isRgisterUser = NO;
    if (_faildBlock != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock();
        });
    }
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    _isRgisterUser = NO;
    [_xmppStream authenticateWithPassword:[LoginUser sharedLoginUser].password error:nil];
}

#pragma mark - 用户登录状态变化
- (void)showStroyboardWithLogonState:(BOOL)isUserLogon
{
    UIStoryboard *storyboard = nil;
    if (isUserLogon)
    {
        //显示Main.storyboard
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    else
    {
        //显示Login.storyboard
        storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    }
    //在主线程队列负责切换storyboard，而不影响后台代理数据处理
    dispatch_async(dispatch_get_main_queue(), ^{
        //把Storyboard的初始视图控制器设置为window的rootViewController
        [self.window setRootViewController:storyboard.instantiateInitialViewController];
        
        if (![self.window isKeyWindow])
        {
            [self.window makeKeyAndVisible];
        }
    });
}

#pragma mark 用户展现变化
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"接收到用户展现数据 -- %@", presence);
    //1.判断接收到的presence类型是否为subscribe
    if ([presence.type isEqualToString:@"subscribe"])
    {
        //1.1取出presence中的from的jid并添加好友
        XMPPJID *from = [presence from];
        //1.2接收来自from的订阅请求
        [_xmppRoster acceptPresenceSubscriptionRequestFrom:from andAddToRoster:YES];
    }
}

#pragma mark 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"接收到用户消息 - %@", message);
}

#pragma mark XMPPRoster代理
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"接收其他用户的请求:%@",presence);
}
@end
