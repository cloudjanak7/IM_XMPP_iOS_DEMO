//
//  AddFriendViewController.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/19.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "AddFriendViewController.h"
#import "AppDelegate.h"

@interface AddFriendViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *friendNameText;

@end

@implementation AddFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_friendNameText becomeFirstResponder];
}

#pragma mark -  text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //1.判断文本框中是否输入了内容
    NSString *name = [textField.text trimString];
    //2.如果输入，调用添加好友方法
    if (![name isEmptyString])
    {
        [self addFriendWithName:name];
    }
    
    return YES;
}

#pragma mark - 添加好友
- (void)addFriendWithName:(NSString *)name
{
    //1.判断输入是否有域名
    NSRange range = [name rangeOfString:@"@127.0.0.1"];
    if (NSNotFound == range.location)
    {
        //2.如果没有，添加域名合成完整的JID字符串
        name = [NSString stringWithFormat:@"%@@%@",name,[LoginUser sharedLoginUser].hostName];
    }
    //3.判断是否与当前用户相同
    if ([name isEqualToString:[LoginUser sharedLoginUser].myJIDName])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"自己不能添加自己" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    //4.判断是否已经是自己的好友
    //userExistsWithJID方法仅用于检测JID是否是用户的好友，而不是检测是否是合法的用户
    if ([[xmppDelegate xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name] xmppStream:[xmppDelegate xmppStream]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友已经是好友无需添加" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    //5.发送订阅请求
    [[xmppDelegate xmppRoster] subscribePresenceToUser:[XMPPJID jidWithString:name]];
    //6.提示用户并返回上级页面
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友请求已发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
