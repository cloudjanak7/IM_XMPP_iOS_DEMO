//
//  UIStoryboard+CH.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/11.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "UIStoryboard+CH.h"

@implementation UIStoryboard (CH)

+ (void)showInitialVCWithName:(NSString *)name
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
}

@end
