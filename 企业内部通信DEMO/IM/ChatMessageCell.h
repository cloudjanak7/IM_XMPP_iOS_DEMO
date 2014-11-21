//
//  ChatMessageCell.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageWidthConstraint;

- (void)setMessage:(NSString *)message isOutgoing:(BOOL)isOutgoing;

@end
