//
//  EmoteSelectorView.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmoteSelectorViewDelegate <NSObject>

- (void)emoteSelectorViewSelectEmoteString:(NSString *)emote;

- (void)emoteSelectorViewRemoveChar;

@end

@interface EmoteSelectorView : UIView

@property (nonatomic, weak) id<EmoteSelectorViewDelegate> delegate;

@end
