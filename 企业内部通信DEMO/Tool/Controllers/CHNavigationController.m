//
//  CHNavigationController.m
//  XMPP微信
//
//  Created by 孙晨辉 on 15/2/28.
//  Copyright (c) 2015年 孙晨辉. All rights reserved.
//

#import "CHNavigationController.h"


@interface CHNavigationController ()

@end

@implementation CHNavigationController

+ (void)initialize
{
    //设置导航样式
    //1.设置导航栏主题
    [self setupNavTheme];
    //2.设置导航栏按钮主题
    [self setupBarButtonItemTheme];

}

/**
 *  设置导航样式
 */
+ (void)setupNavTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    //1.设置导航条背景(高度不会拉伸，宽度会拉伸)
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    
    //2.设置导航栏的字体
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[UITextAttributeTextColor] = [UIColor whiteColor];
    textAttrs[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
    textAttrs[UITextAttributeFont] = [UIFont boldSystemFontOfSize:19];
    [navBar setTitleTextAttributes:textAttrs];
    
    navBar.tintColor = [UIColor whiteColor];
    
    //3.设置状态栏样式(默认状态栏的样式由控制器决定，需要在list -> View controller-based status bar appearance)
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark 设置导航栏按钮主题
+ (void)setupBarButtonItemTheme
{
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    //设置文字属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[UITextAttributeTextColor] = [UIColor whiteColor];
    textAttrs[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
    textAttrs[UITextAttributeFont] = [UIFont systemFontOfSize:15];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateHighlighted];
    
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    disableTextAttrs[UITextAttributeTextColor] = [UIColor grayColor];
    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
}

@end
