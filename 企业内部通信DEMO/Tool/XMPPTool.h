//
//  XMPPTool.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

extern NSString *const CHLoginStatusChangeNotification;

typedef enum {
    XMPPResultTypeConnecting,//连接中...
    XMPPResultTypeNetError, // 网络不给力
    XMPPResultTypeLoginSuccess, // 登录成功
    XMPPResultTypeLoginFailure, // 登录失败
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure // 注册失败
}XMPPResultType;

@interface XMPPTool : NSObject
singleton_interface(XMPPTool)

//全局的xmppStream
@property (strong, nonatomic, readonly) XMPPStream *xmppStream;
/** 电子名片 */
@property (strong, nonatomic, readonly) XMPPvCardTempModule *xmppvCardModule;
/** 头像模块 */
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
/** 花名册数据存储 */
@property (strong, nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
/** 花名册模块 */
@property (strong, nonatomic, readonly) XMPPRoster *xmppRoster;
/** 聊天模块存储 */
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
/** 注册操作YES:注册，NO:登录 */
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

/**
 *  用户登录
 */
- (void)xmppUserLogin:(void (^)(XMPPResultType type))result;

/**
 *  注销
 */
- (void)xmppUserLogout;

/**
 *  用户注册
 */
- (void)xmppUserRegister:(void (^)(XMPPResultType))result;


@end
