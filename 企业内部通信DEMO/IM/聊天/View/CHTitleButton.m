//
//  SCHTitleButton.m
//  微博
//
//  Created by 孙晨辉 on 14/12/24.
//  Copyright (c) 2014年 孙晨辉. All rights reserved.
//

#import "CHTitleButton.h"

#define CHTitleButtonImageW 20

@implementation CHTitleButton

+ (instancetype)titleButton
{
    return [[self alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenDisabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:19];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.contentMode = UIViewContentModeCenter;
        [self setBackgroundColor:[UIColor redColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageY = 0;
    CGFloat imageW = CHTitleButtonImageW;
    CGFloat imageX = contentRect.size.width - imageW;
    CGFloat imageH = contentRect.size.height;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = 5;
    CGFloat titleW = contentRect.size.width - CHTitleButtonImageW;
    CGFloat titleH = contentRect.size.height;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    CGFloat titleW = [title sizeWithFont:self.titleLabel.font].width;
    CGRect frame = self.frame;
    if (self.imageView.image)
    {
        frame.size.width = titleW + CHTitleButtonImageW + 5;
    }
    else
    {
        frame.size.width = titleW;
    }
    self.frame = frame;
    [super setTitle:title forState:state];
}

@end
