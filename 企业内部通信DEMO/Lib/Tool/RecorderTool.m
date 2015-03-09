//
//  RecorderTool.m
//  声音播放
//
//  Created by 孙晨辉 on 14/11/25.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "RecorderTool.h"

@interface RecorderTool ()
{
    NSURL *_url;
}

/** 播放录音 */
@property (nonatomic, strong) AVAudioPlayer *player;
/** 录音 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end
@implementation RecorderTool
singleton_implementation(RecorderTool)

- (id)init
{
    self = [super init];
    if (self)
    {
        //0.设置音频会话，允许录音
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //激活分类
        [session setActive:YES error:nil];
    }
    return self;
}

- (void)createRecorderName:(NSString *)name
{
    //1.实例化录音机
    //1)保存录音文件的url
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [docs[0] stringByAppendingPathComponent:name];
    NSURL *url = [NSURL fileURLWithPath:path];
    //2)录音文件设置字典(设置音频的属性，例如音轨数量，音频格式)
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self recorderSettings] error:&error];
    if (error)
    {
        NSLog(@"录音机实例化失败 - %@", error.localizedDescription);
    }
    _url = url;
    _urlPath = path;
}

#pragma mark - 成员方法
#pragma mark 是否正在录音
- (BOOL)isRecording
{
    return [_recorder isRecording];
}

#pragma mark 开始录音
- (void)startRecording
{
    //如果当前正在录音
    if ([_recorder isRecording])
    {
        return;
    }
    //如果正在播放
    if ([_player isPlaying])
    {
        [_player stop];
    }
    [_recorder record];
    NSLog(@"record -- %d", [_recorder isRecording]);
}

#pragma mark 结束录音
- (void)stopRecording
{
    if ([_recorder isRecording])
    {
        _currentTime = _recorder.currentTime;
        [_recorder stop];
    }
}

#pragma mark 开始播放
- (void)startPlaying
{
    //3)实例化播放器
    _player = [SoundTool audioPlayerWithURL:_url];
    [_player setNumberOfLoops:0];
    [_player prepareToPlay];
    [_player play];
}

#pragma mark 结束播放
- (void)stopPlaying
{
    if ([_player isPlaying])
    {
        [_player stop];
    }
}

#pragma mark - private
#pragma mark 录音设置
- (NSDictionary *)recorderSettings
{
    NSMutableDictionary *setting = [[NSMutableDictionary alloc] init];
    //音频格式
    [setting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    //音频采样率
    [setting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    //音频通道数
    [setting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性音频的位深度
    [setting setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    return setting;
}

@end
