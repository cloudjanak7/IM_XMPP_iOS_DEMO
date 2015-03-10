//
//  UIImage+CH.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/5.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CH)

/**
 *  比例缩放图片
 *
 *  @param targetSize 目标的大小
 */
- (UIImage *)imageByScallingAspectToMaxSize:(CGSize)targetSize;

/**
 *  获取缩放后的图片大小
 */
- (CGSize)imageSizeReturnByScallingAspectToMaxSize:(CGSize)targetSize;

/**
 *  拉伸图片
 *
 *  @param targetSize 目标的大小
 */
- (UIImage *)stretchableImageWithSize:(CGSize)targetSize;

@end
