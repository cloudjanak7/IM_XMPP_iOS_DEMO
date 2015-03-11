//
//  UIStoryboard+CH.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/11.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (CH)

/**
 *  显示新的控制器
 *
 *  @param name 控制器名
 */
+(void)showInitialVCWithName:(NSString *)name;

@end
