//
//  UserInfo.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

static NSString *XMPPDomain = @"127.0.0.1";
@interface UserInfo : NSObject

singleton_interface(UserInfo)

/** 用户名 */
@property (nonatomic, copy) NSString *user;
/** 密码 */
@property (nonatomic, copy) NSString *pwd;
/** 主机服务器 */
@property (nonatomic, copy) NSString *hostName;
/** 登录状态YES:登录,NO:注销 */
@property (nonatomic, assign) BOOL loginStatus;
/** 注册用户名 */
@property (nonatomic, copy) NSString *registerUser;
/** 注册密码 */
@property (nonatomic, copy) NSString *registerPwd;
/** 当前用户jid */
@property (nonatomic, copy) NSString *jid;

/** 登录成功后保存至沙盒 */
- (void)saveUserInfoToSandbox;

/** 从沙盒加载用户数据 */
- (void)loadUserInfoFromSandbox;

@end
