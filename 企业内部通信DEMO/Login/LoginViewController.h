//
//  LoginViewController.h
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *userNameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *hostNameText;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@end
