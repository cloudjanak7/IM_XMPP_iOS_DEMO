//
//  UIImage+CH.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/5.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CH)

#pragma mark 成员方法
/**
 *  比例缩放图片 （在范围内）
 *
 *  @param targetSize 目标的大小
 */
- (UIImage *)imageByScallingAspectToMaxSize:(CGSize)targetSize;

/**
 *  比例缩放图片 （可在范围外）
 *
 *  @param targetSize 目标的大小
 */
- (UIImage *)imageByScallingAspectToMinSize:(CGSize)targetSize;

/**
 *  获取缩放后的图片大小
 */
- (CGSize)imageSizeReturnByScallingAspectToMaxSize:(CGSize)targetSize;

/**
 *  获取缩放后的图片大小
 */
- (CGSize)imageSizeReturnByScallingAspectToMinSize:(CGSize)targetSize;

/**
 *  拉伸图片（暂未实现）
 *
 *  @param targetSize 目标的大小
 */
- (UIImage *)stretchableImageWithSize:(CGSize)targetSize;

/**
 *  设置拉伸图片方式
 *
 *  @param img 要拉伸的图片
 */
- (UIImage *)stretcheImage;

#pragma mark - 类方法
/**
 *  设置拉伸图片方式
 *
 *  @param imageName 要拉伸的图片名
 */
+ (UIImage *)stretchedImageWithName:(NSString *)imageName;

@end
