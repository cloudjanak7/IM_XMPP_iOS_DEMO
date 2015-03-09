//
//  EmoteSelectorView.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "EmoteSelectorView.h"

static unichar emotechars[28] =
{
    0xe415, 0xe056, 0xe057, 0xe414, 0xe405, 0xe106, 0xe418,
    0xe417, 0xe40d, 0xe40a, 0xe404, 0xe105, 0xe409, 0xe40e,
    0xe402, 0xe108, 0xe403, 0xe058, 0xe407, 0xe401, 0xe416,
    0xe40c, 0xe406, 0xe413, 0xe411, 0xe412, 0xe410, 0xe059,
};

#define kRowCount 4
#define kColCount 7
#define kStartPoint CGPointMake(6,20)
#define kButtonSize CGSizeMake(44,44)

@implementation EmoteSelectorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        for (NSInteger i = 0; i < 28; i ++)
        {
            //创建按钮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            NSString *string = [self emoteStringWithIndex:i];
            [button setTitle:string forState:UIControlStateNormal];
            if (i == 27)
            {
                // 最末尾的删除按钮，设置按钮图像
                UIImage *img = [UIImage imageNamed:@"DeleteEmoticonBtn"];
                UIImage *imgHL = [UIImage imageNamed:@"DeleteEmoticonBtnHL"];
                [button setTitle:@"" forState:UIControlStateNormal];
                [button setImage:img forState:UIControlStateNormal];
                [button setImage:imgHL forState:UIControlStateHighlighted];
            }
            [button addTarget:self action:@selector(clickEmote:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //当前控制器大小
    CGFloat currentW = [UIScreen mainScreen].bounds.size.width;
    //水平间距
    CGFloat totalMarginW = currentW - kStartPoint.x * 2 - kColCount * kButtonSize.width;
    CGFloat marginW = totalMarginW / (kColCount - 1);
    
    for (NSInteger row = 0; row < kRowCount; row++)
    {
        for (NSInteger col = 0; col < kColCount; col++)
        {
            //计算按钮索引(第几个按钮)
            NSInteger index = row * kColCount + col;
            UIButton *button = self.subviews[index];
            NSInteger x = kStartPoint.x + col * (kButtonSize.width + marginW);
            NSInteger y = kStartPoint.y + row * kButtonSize.height;
            button.frame = CGRectMake(x, y, kButtonSize.width, kButtonSize.height);
        }
    }
}

#pragma mark - 表情按钮点击事件
- (void)clickEmote:(UIButton *)button
{
    NSString *string = [self emoteStringWithIndex:button.tag];
    if (button.tag != 27)
    {
        [_delegate emoteSelectorViewSelectEmoteString:string];
    }
    else
    {
        [_delegate emoteSelectorViewRemoveChar];
    }
    
}

- (NSString *)emoteStringWithIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%C",emotechars[index]];
}
@end
