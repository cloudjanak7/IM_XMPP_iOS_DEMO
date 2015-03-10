//
//  CHMessageView.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/10.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHMessageView.h"
#import "CHMessageFrame.h"
#import "MessageObject.h"
#import "UIImage+CH.h"

@interface CHMessageView ()
{
    UIImage *_receiveImage;
    UIImage *_receiveImageHL;
    UIImage *_senderImage;
    UIImage *_senderImageHL;
}

@end
@implementation CHMessageView

- (void)awakeFromNib
{
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 20, 10);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
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

- (UIImage *)stretcheImage:(UIImage *)img
{
//    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.6];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.width * 0.6, img.size.width * 0.5, img.size.width * 0.3, img.size.width * 0.5)];
}

- (void)setMsgF:(CHMessageFrame *)msgF
{
    _msgF = msgF;
    // 根据消息文本设置button
    [self setupMessageData];
}

#pragma mark - private
- (void)setupMessageData
{
    if (self.msgF.msgObj.isOutgoing)
    {
        [self setBackgroundImage:_senderImage forState:UIControlStateNormal];
        [self setBackgroundImage:_senderImageHL forState:UIControlStateHighlighted];
    }
    else
    {
        [self setBackgroundImage:_receiveImage forState:UIControlStateNormal];
        [self setBackgroundImage:_receiveImageHL forState:UIControlStateHighlighted];
    }
    
    switch (self.msgF.msgObj.messageType)
    {
        case MessageTypeImage:
            self.imageView.hidden = NO;
            [self setupImageTypeMessage];
            break;
        case MessageTypeRecord:
            self.imageView.hidden = NO;
            if (self.msgF.msgObj.isOutgoing)
            {
                [self setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying003"] forState:UIControlStateNormal];
            }
            else
            {
                [self setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying003"] forState:UIControlStateNormal];
            }
        case MessageTypeText:
            [self setImage:nil forState:UIControlStateNormal];
            self.imageView.hidden = YES;
            [self setTitle:self.msgF.msgObj.messageText forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - private
- (void)setupImageTypeMessage
{
    UIImage *maskImage = nil;
    if (self.msgF.msgObj.isOutgoing)
    {
        maskImage = [UIImage imageNamed:@"SenderImageNodeMask1"];
    }
    else
    {
        maskImage = [UIImage imageNamed:@"ReceiverImageNodeMask1"];
    }
    maskImage = [self stretcheImage:maskImage];
    
    UIImage *image = [self imageWithImage:self.msgF.msgObj.image maskImage:maskImage];
//    [self setImage:image forState:UIControlStateNormal];
    [self setImage:self.msgF.msgObj.image forState:UIControlStateNormal];
}

#pragma mark mask切图
- (UIImage *)imageWithImage:(UIImage *)image maskImage:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    NSLog(@"%@", mask);
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *destImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return destImage;
}

@end
