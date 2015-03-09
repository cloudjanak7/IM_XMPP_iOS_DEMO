//
//  LoginViewController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+Helper.h"
#import "MBProgressHUD+MJ.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *userNameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *hostNameText;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;

/** 登录 */
- (void)login;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hostNameText.text = @"192.168.1.53";
    //拉伸按钮背景图片
    UIImage *loginImage = [UIImage imageNamed:@"LoginGreenBigBtn"];
    loginImage = [loginImage stretchableImageWithLeftCapWidth:loginImage.size.width * 0.5 topCapHeight:loginImage.size.height * 0.5];
    [_loginBtn setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    UIImage *registerImage = [UIImage imageNamed:@"LoginwhiteBtn"];
    registerImage = [registerImage stretchableImageWithLeftCapWidth:registerImage.size.width * 0.5 topCapHeight:registerImage.size.height * 0.5];
    [_registerBtn setBackgroundImage:registerImage forState:UIControlStateNormal];
    
    self.userNameText.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.passwordText.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.hostNameText.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    //设置用户名为上次登录的用户名
    //从沙盒获取用户名
    NSString *user = [UserInfo sharedUserInfo].user;
    self.userNameText.text = user;
    
    if ([_userNameText.text isEmptyString])
    {
        [_userNameText becomeFirstResponder];
    }
    else
    {
        [_passwordText becomeFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 按钮点击事件
#pragma mark 登录事件
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
    
    UserInfo *userInfo = [UserInfo sharedUserInfo];
    userInfo.user = self.userNameText.text;
    userInfo.pwd = self.passwordText.text;
    userInfo.hostName = self.hostNameText.text;
    
    //登录
    [self login];
}

#pragma mark 注册事件
- (IBAction)registClick:(id)sender
{
    UserInfo *userInfo = [UserInfo sharedUserInfo];
    userInfo.registerUser = self.userNameText.text;
    userInfo.registerPwd = self.passwordText.text;
    userInfo.hostName = self.hostNameText.text;
    XMPPTool *xmppTool = [XMPPTool sharedXMPPTool];
    xmppTool.registerOperation = YES;
    
    [MBProgressHUD showMessage:@"正在注册" toView:self.view];
    __weak typeof(self) vc = self;
    [xmppTool xmppUserRegister:^(XMPPResultType type) {
        [vc handleResultType:type];
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

#pragma mark - private
#pragma mark 登录
- (void)login
{
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"正在登录" toView:self.view];
    XMPPTool *xmppTool = [XMPPTool sharedXMPPTool];
    xmppTool.registerOperation = NO;
    __weak typeof(self) vc = self;
    
    [xmppTool xmppUserLogin:^(XMPPResultType type) {
        [vc handleResultType:type];
    }];
}

#pragma mark 登录返回
- (void)handleResultType:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type)
        {
            case XMPPResultTypeLoginSuccess:
                [self enterMainVC];
                break;
            case XMPPResultTypeLoginFailure:
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                break;
            case XMPPResultTypeNetError:
                [MBProgressHUD showError:@"网络连接错误" toView:self.view];
                break;
            case XMPPResultTypeRegisterSuccess:
                [MBProgressHUD showSuccess:@"注册成功" toView:self.view];
                [self userLogin:nil];
                break;
            case XMPPResultTypeRegisterFailure:
                [MBProgressHUD showError:@"注册失败\n用户名重复" toView:self.view];
                break;
            default:
                break;
        }
    });
}

#pragma mark 进入主界面
- (void)enterMainVC
{
    [UserInfo sharedUserInfo].loginStatus = YES;
    //保存数据至沙盒
    [[UserInfo sharedUserInfo] saveUserInfoToSandbox];
    //隐藏模态窗口
    [self dismissViewControllerAnimated:NO completion:nil];
    //登录成功来到主界面
    [UIStoryboard showInitialVCWithName:@"Main"];
}

@end
