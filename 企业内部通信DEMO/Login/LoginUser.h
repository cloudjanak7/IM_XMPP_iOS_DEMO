//
//  LoginUser.h
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LoginUser : NSObject
single_interface(LoginUser)

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *hostName;

@property (strong, nonatomic, readonly) NSString *myJIDName;

@end
