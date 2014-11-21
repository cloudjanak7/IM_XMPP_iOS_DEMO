//
//  RosterTests.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/19.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"

@interface RosterTests : XCTestCase

@property (nonatomic, strong) AppDelegate *delegate;

@end

@implementation RosterTests

- (void)setUp {
    [super setUp];
    //做初始化工作
    self.delegate = xmppDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSString *name = @"guo@127.0.0.1";
    BOOL exist = [[xmppDelegate xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name] xmppStream:[xmppDelegate xmppStream]];
    NSLog(@" --------- %d", exist);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
