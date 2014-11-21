//
//  ChatMessageCell.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "ChatMessageCell.h"

@interface ChatMessageCell ()
{
    UIImage *_receiveImage;
    UIImage *_receiveImageHL;
    UIImage *_senderImage;
    UIImage *_senderImageHL;
}

@end

@implementation ChatMessageCell

- (UIImage *)stretcheImage:(UIImage *)img
{
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.6];
}

- (void)awakeFromNib
{
    _receiveImage = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    _receiveImageHL = [UIImage imageNamed:@"ReceiverTextNodeBkgHL"];
    _senderImage = [UIImage imageNamed:@"SenderTextNodeBkg"];
    _senderImageHL = [UIImage imageNamed:@"SenderTextNodeBkgHL"];
    
    //处理图像拉伸(因为iOS 6不支持图像切片)
    _receiveImage = [self stretcheImage:_receiveImage];
    _receiveImageHL = [self stretcheImage:_receiveImageHL];
    _senderImageHL = [self stretcheImage:_senderImageHL];
    _senderImage = [self stretcheImage:_senderImage];
}

- (void)setMessage:(NSString *)message isOutgoing:(BOOL)isOutgoing
{
    if (isOutgoing)
    {
        [_messageButton setBackgroundImage:_senderImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_senderImageHL forState:UIControlStateHighlighted];
    }
    else
    {
        [_messageButton setBackgroundImage:_receiveImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_receiveImageHL forState:UIControlStateHighlighted];
    }
    
    //2.设置按钮文字
    //2.1计算文字占用的区间
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, MAXFLOAT)];
    //2.2使用文本占用空间设置约束
    //提示：需要考虑到在stroyboard中设置的间距
    _messageHeightConstraint.constant = size.height + 30.0;
    _messageWidthConstraint.constant = size.width + 30.0;
    
    //2.3设置按钮文字
    [_messageButton setTitle:message forState:UIControlStateNormal];
    
    //2.4重新调整布局
    [self setNeedsDisplay];
}

@end
