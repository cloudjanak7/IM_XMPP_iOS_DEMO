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
    
    CHLog(@"图片宽:%f 高:%f", width, height);
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat xFactor = targetWidth / width;
        // 根据缩放引资计算图片缩放后的宽度和高度
        scaledHeight = height * xFactor;
        scaledWidth = width * xFactor;
        anchorPoint.y = (targetHeight - scaledHeight) * 0.5;
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect anchorRect = CGRectZero;
    anchorRect.origin = anchorPoint;
    anchorRect.size = CGSizeMake(scaledWidth, scaledHeight);
    
    [self drawInRect:anchorRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CHLog(@"newImage - %@", NSStringFromCGSize(newImage.size));
    return newImage;
}

- (UIImage *)imageByScallingAspectToMinSize:(CGSize)targetSize
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
        //水平缩放因子
        CGFloat xFactor = targetWidth / width;
        //垂直缩放因子
        CGFloat yFactor = targetHeight / height;
        
        CGFloat scaleFactor = xFactor > yFactor ? xFactor : yFactor;
        
        //缩放后宽高
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
    
        if (xFactor > yFactor)
        {
            anchorPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
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
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat xFactor = targetWidth / width;
        // 根据缩放引资计算图片缩放后的宽度和高度
        scaledHeight = height * xFactor;
        scaledWidth = width * xFactor;
    }
    return CGSizeMake(scaledWidth, scaledHeight);
}

- (CGSize)imageSizeReturnByScallingAspectToMinSize:(CGSize)targetSize
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
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        //水平缩放因子
        CGFloat xFactor = targetWidth / width;
        //垂直缩放因子
        CGFloat yFactor = targetHeight / height;
        
        CGFloat scaleFactor = xFactor > yFactor ? xFactor : yFactor;
        
        //缩放后宽高
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
    }
    
    return CGSizeMake(scaledWidth, scaledHeight);
}

- (UIImage *)stretchableImageWithSize:(CGSize)targetSize
{
    return nil;
}

#pragma mark 拉伸图片
- (UIImage *)stretcheImage
{
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height * 0.6, self.size.width * 0.2, self.size.height * 0.3, self.size.width * 0.2)];
}

#pragma mark - 类方法
+ (UIImage *)stretchedImageWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    int leftCap = image.size.width * 0.5;
    int topCap = image.size.height * 0.5;
    return [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

@end
