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
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:28];
        for (NSInteger row = 0; row < kRowCount; row++)
        {
            for (NSInteger col = 0; col < kColCount; col++)
            {
                //计算按钮索引(第几个按钮)
                NSInteger index = row * kColCount + col;
                //创建按钮
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                NSInteger x = kStartPoint.x + col * kButtonSize.width;
                NSInteger y = kStartPoint.y + row * kButtonSize.height;
                button.frame = CGRectMake(x, y, kButtonSize.width, kButtonSize.height);
                button.tag = index;
                [arrayM addObject:button];

                [button addTarget:self action:@selector(clickEmote:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
            }
        }
        for (UIButton *btn in arrayM)
        {
            if (btn.tag == 27)
            {
                UIImage *image = [UIImage imageNamed:@"DeleteEmoticonBtn"];
                UIImage *imageHL = [UIImage imageNamed:@"DeleteEmoticonBtnHL"];
                [btn setImage:image forState:UIControlStateNormal];
                [btn setImage:imageHL forState:UIControlStateHighlighted];
            }
            else
            {
                NSString *string = [self emoteStringWithIndex:btn.tag];
                [btn setTitle:string forState:UIControlStateNormal];
            }
        }
    }
    return self;
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
