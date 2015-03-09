//
//  CHTalkingCell.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/5.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHTalkingCell.h"

@implementation CHTalkingCell

+ (instancetype)cellViewTableView:(UITableView *)tableView
{
    static NSString *ID = @"TalkingCell";
    CHTalkingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[CHTalkingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
