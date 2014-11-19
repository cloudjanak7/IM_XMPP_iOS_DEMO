//
//  AppDelegate.h
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-9-28.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

#define xmppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

typedef void(^completionBlock)();
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//全局的xmppStream
@property (strong, nonatomic, readonly) XMPPStream *xmppStream;
//全局的xmppvCardModule
@property (strong, nonatomic, readonly) XMPPvCardTempModule *xmppvCardModule;
//全局XMPPRoster模块
@property (strong, nonatomic, readonly) XMPPRoster *xmppRoster;
//全局XMPPRosterCoreDataStorage模块
@property (strong, nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;

@property (nonatomic, assign) BOOL isRgisterUser;

//@property (nonatomic, assign) BOOL isUserLogin;

/**
 *
 *连接到服务器
 *用户信息保存在系统偏好中
 *@param completion 连接正确的代码
 *@param faild 连接错误的代码
 */
- (void)connectWithcompletion:(completionBlock)completion failed:(completionBlock)faild;

- (void)logout;
@end
