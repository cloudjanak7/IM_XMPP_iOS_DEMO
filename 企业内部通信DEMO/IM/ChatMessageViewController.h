//
//  ChatMessageViewController.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/19.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageViewController : UIViewController

//对话方JID
@property (nonatomic, strong) NSString *bareJidStr;
//对话方头像
@property (nonatomic, strong) UIImage *bareImage;
//我的头像
@property (nonatomic, strong) UIImage *myImage;

@end
