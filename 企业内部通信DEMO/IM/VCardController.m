//
//  VCardController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "VCardController.h"
#import "AppDelegate.h"

@interface VCardController ()

@end

@implementation VCardController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}


- (IBAction)logout:(id)sender
{
    [[self appDelegate] logout];
}

#pragma mark - AppDelegate助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}
@end
