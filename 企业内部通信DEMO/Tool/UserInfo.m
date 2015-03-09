//
//  UserInfo.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "UserInfo.h"

#define UserKey @"user"
#define PwdKey @"pwd"
#define HostKey @"hostName"
#define LoginStatus @"loginStatus"

@implementation UserInfo
singleton_implementation(UserInfo)

- (void)saveUserInfoToSandbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:UserKey];
    [defaults setObject:self.hostName forKey:HostKey];
    [defaults setBool:self.loginStatus forKey:LoginStatus];
    [defaults setObject:self.pwd forKey:PwdKey];
    [defaults synchronize];
}

- (void)loadUserInfoFromSandbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.user = [defaults objectForKey:UserKey];
    self.pwd = [defaults objectForKey:PwdKey];
    self.hostName = [defaults objectForKey:HostKey];
    self.loginStatus = [defaults boolForKey:LoginStatus];
}

- (NSString *)jid
{
    return [NSString stringWithFormat:@"%@@%@", self.user, XMPPDomain];
}

@end
