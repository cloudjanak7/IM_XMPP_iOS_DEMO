//
//  LoginViewController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+Helper.h"
#import "AppDelegate.h"
#import "LoginUser.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - AppDelegate助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _hostNameText.text = @"192.168.1.53";
    //拉伸按钮背景图片
    UIImage *loginImage = [UIImage imageNamed:@"LoginGreenBigBtn"];
    loginImage = [loginImage stretchableImageWithLeftCapWidth:loginImage.size.width * 0.5 topCapHeight:loginImage.size.height * 0.5];
    [_loginBtn setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    UIImage *registerImage = [UIImage imageNamed:@"LoginwhiteBtn"];
    registerImage = [registerImage stretchableImageWithLeftCapWidth:registerImage.size.width * 0.5 topCapHeight:registerImage.size.height * 0.5];
    [_registerBtn setBackgroundImage:registerImage forState:UIControlStateNormal];
    
    _userNameText.text = [[LoginUser sharedLoginUser] userName];
    _passwordText.text = [[LoginUser sharedLoginUser] password];
    _hostNameText.text = [[LoginUser sharedLoginUser] hostName];
    
    if ([_userNameText.text isEmptyString])
    {
        [_userNameText becomeFirstResponder];
    }
    else
    {
        [_passwordText becomeFirstResponder];
    }
    
}

- (IBAction)userLogin:(UIButton *)button
{
    //检查用户输入是否完整
    NSString *userName = [_userNameText.text trimString];
    NSString *password = _passwordText.text;
    NSString *hostName = [_hostNameText.text trimString];
    if ([userName isEmptyString] || [password isEmptyString] || [hostName isEmptyString])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录信息不完整" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //写入系统偏好
    [[LoginUser sharedLoginUser] setUserName:userName];
    [[LoginUser sharedLoginUser] setPassword:password];
    [[LoginUser sharedLoginUser] setHostName:hostName];
    
    NSString *errorMessage = nil;
    if (button.tag == 1)
    {
        [self appDelegate].isRgisterUser = YES;
        errorMessage = @"注册用户失败";
    }
    else
    {
        errorMessage = @"用户登录失败";
    }
    
    //让AppDelegate开始连接
    //连接成功或失败后提示用户
    [[self appDelegate] connectWithcompletion:nil failed:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        if (button.tag == 1)
        {
            [_userNameText becomeFirstResponder];
        }
        else
        {
            _passwordText.text = @"";
            [_passwordText becomeFirstResponder];
        }
    }];
    
}

#pragma mark - UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameText)
    {
        [_passwordText becomeFirstResponder];
    }
    else if (textField == _passwordText && [_hostNameText.text isEmptyString])
    {
        [_hostNameText becomeFirstResponder];
    }
    else
    {
        [self userLogin:nil];
    }
    return YES;
}

@end
