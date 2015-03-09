//
//  AppDelegate.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-9-28.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "CHNavigationController.h"

#define kNotificationUserLogonState @"NotificationUserLogon"
@interface AppDelegate ()
{
    
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    //打开XMPP日志
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // 设置导航栏背景
    [CHNavigationController setupNavTheme];
    
    //从沙盒中获取用户数据至单例
    [[UserInfo sharedUserInfo] loadUserInfoFromSandbox];
    
    if ([UserInfo sharedUserInfo].loginStatus)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
        
        //自动登录服务器
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[XMPPTool sharedXMPPTool] xmppUserLogin:nil];
        });

    }
    
    // 注册应用接收通知
    if (iOS8)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

@end
