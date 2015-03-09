//
//  CHCoreDataTool.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/7.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHCoreDataTool : NSObject

/**
 *  根据模型文件，返回上下文
 */
+ (NSManagedObjectContext *)setupContextWithModelName:(NSString *)modelName;

@end
