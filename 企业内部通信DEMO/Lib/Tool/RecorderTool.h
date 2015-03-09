//
//  RecorderTool.h
//  声音播放
//
//  Created by 孙晨辉 on 14/11/25.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "SoundTool.h"

@interface RecorderTool : NSObject
singleton_interface(RecorderTool)

@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 创建录音器 */
- (void)createRecorderName:(NSString *)name;

#pragma mark 开始录音
- (void)startRecording;

#pragma mark 结束录音
- (void)stopRecording;

#pragma mark 开始播放
- (void)startPlaying;

#pragma mark 结束播放
- (void)stopPlaying;

#pragma mark 是否正在录音
- (BOOL)isRecording;

@end
