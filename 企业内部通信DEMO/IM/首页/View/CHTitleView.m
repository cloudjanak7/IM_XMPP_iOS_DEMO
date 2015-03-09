//
//  CHTitleView.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHTitleView.h"

#define CHTitleViewFont [UIFont systemFontOfSize:19]
#define CHTitleViewFontBold [UIFont systemFontOfSize:19]

#define CHMagin 15;

@interface CHTitleView ()

/** 标题Label */
@property (nonatomic, strong) UILabel *titleLabel;
/** 活动指示器 */
@property (nonatomic, weak) UIActivityIndicatorView *activityView;

@end

@implementation CHTitleView

+ (instancetype)titleView
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = CHTitleViewFont;
        self.titleLabel.font = CHTitleViewFontBold;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityView stopAnimating];
        activityView.hidesWhenStopped = YES;
        self.activityView = activityView;
        [self addSubview:activityView];
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
    // 计算Label大小
    CGSize titleLabelS = [self.titleLabel.text sizeWithAttributes:@{UITextAttributeFont:CHTitleViewFont}];
    CGSize activityViewS = self.activityView.bounds.size;
    
    CGFloat frameH = titleLabelS.height;
    CGFloat frameW = 0;
    if (self.isLoading)
    {
        frameW = titleLabelS.width + activityViewS.width + CHMagin;
    }
    else
    {
        frameW = titleLabelS.width;
    }
    
    self.bounds = (CGRect){CGPointZero, CGSizeMake(frameW , frameH)};
    
    self.titleLabel.frame = (CGRect){CGPointZero, titleLabelS};
    
    CGFloat activityX = CGRectGetMaxX(self.titleLabel.frame) + CHMagin;
    CGFloat activityY = (titleLabelS.height - activityViewS.height) / 2.0;
    self.activityView.frame = (CGRect){CGPointMake(activityX, activityY), activityViewS};
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    [self setTitle:self.title];
    if (loading)
    {
        [self.activityView startAnimating];
    }
    else
    {
        [self.activityView stopAnimating];
    }
}

@end
