//
//  BackButton.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHBackButton.h"

#define CHBackButtonImageW 20

@implementation CHBackButton

+ (instancetype)backButton
{
    return [[self alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenDisabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageY = 0;
    CGFloat imageW = CHBackButtonImageW;
    CGFloat imageX = 0;
    CGFloat imageH = contentRect.size.height;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = 0;
    CGFloat titleW = contentRect.size.width - CHBackButtonImageW;
    CGFloat titleX = contentRect.size.width - titleW;
    CGFloat titleH = contentRect.size.height;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    CGFloat titleW = [title sizeWithFont:self.titleLabel.font].width;
    CGRect frame = self.frame;
    frame.size.width = titleW + CHBackButtonImageW + 5;
    self.frame = frame;
    [super setTitle:title forState:state];
}

@end
