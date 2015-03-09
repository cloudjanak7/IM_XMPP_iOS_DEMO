//
//  NSArray+Log.m
//
//  Created by 刘凡 on 13-11-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithFormat:@"【count:%u】 (\n", (unsigned int)self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@", obj];

        if (idx < self.count - 1) {
            [strM appendString:@",\n"];
        }
    }];
    [strM appendString:@"\n)"];

    return strM;
}

@end

@implementation NSDictionary (NSLog)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"{\n"];
    for (NSString *keyStr in self.allKeys)
    {
        [strM appendFormat:@"\t\"%@\" = %@,\n", keyStr, self[keyStr]];
    }
    
    [strM appendString:@"}"];
    
    NSRange range = [strM rangeOfString:@"," options:NSBackwardsSearch];
    
    if (range.length > 0)
    {
        [strM deleteCharactersInRange:range];
    }
    
    
    return strM;
}

@end

