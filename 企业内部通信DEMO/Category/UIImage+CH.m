//
//  UIImage+CH.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/5.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "UIImage+CH.h"

@implementation UIImage (CH)

- (UIImage *)imageByScallingAspectToMaxSize:(CGSize)targetSize
{
    // 获取图片宽高
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    // 目标大小
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint anchorPoint = CGPointZero;
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat xFactor = targetWidth / width;
        CGFloat yFactor = targetHeight / height;
        
        CGFloat scaleFactor = xFactor < yFactor ? xFactor : yFactor;
        // 根据缩放引资计算图片缩放后的宽度和高度
        scaledHeight = height * scaleFactor;
        scaledWidth = width * scaleFactor;
        
        if (xFactor < yFactor)
        {
            anchorPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (xFactor > yFactor)
        {
            anchorPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect anchorRect = CGRectZero;
    anchorRect.origin = anchorPoint;
    anchorRect.size = CGSizeMake(scaledWidth, scaledHeight);
    
    [self drawInRect:anchorRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGSize)imageSizeReturnByScallingAspectToMaxSize:(CGSize)targetSize
{
    // 获取图片宽高
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    // 目标大小
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint anchorPoint = CGPointZero;
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat xFactor = targetWidth / width;
        CGFloat yFactor = targetHeight / height;
        
        CGFloat scaleFactor = xFactor < yFactor ? xFactor : yFactor;
        // 根据缩放引资计算图片缩放后的宽度和高度
        scaledHeight = height * scaleFactor;
        scaledWidth = width * scaleFactor;
        
        if (xFactor < yFactor)
        {
            anchorPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (xFactor > yFactor)
        {
            anchorPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    return CGSizeMake(scaledWidth, scaledHeight);
}

@end
