//
//  CHCoreDataTool.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/7.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHCoreDataTool.h"

@implementation CHCoreDataTool

+ (NSManagedObjectContext *)setupContextWithModelName:(NSString *)modelName
{
    //1.创建模型文件[相当于数据库里的表]
    //2.添加实体
    //3.创建实体类[相当于数据模型]
    //4.生成上下文 关联模型文件生成数据库
    //上下文
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    //关联数据
    //模型文件
    NSURL *companyURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:companyURL];
    
    //持久化存储调度器 NSPersistentStoreCoordinator
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 告诉CoreData数据库的名字和路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *name = [NSString stringWithFormat:@"%@.sqlite", modelName];
    NSString *sqlitePath = [path stringByAppendingPathComponent:name];
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:nil];
    
    context.persistentStoreCoordinator = store;
    return context;
}

@end
