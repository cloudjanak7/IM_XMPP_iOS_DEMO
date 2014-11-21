//
//  InputTextView.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "InputTextView.h"
#import "EmoteSelectorView.h"

@interface InputTextView ()<EmoteSelectorViewDelegate>
//表情选择视图
@property (nonatomic, strong) EmoteSelectorView *emoteSelectorView;

@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
//录音按钮
@property (nonatomic, weak) IBOutlet UIButton *recorderButton;
//输入文本
@property (nonatomic, weak) IBOutlet UITextField *inputText;

- (IBAction)clickVoice:(UIButton *)button;
- (IBAction)clickEmote:(UIButton *)button;

@end

@implementation InputTextView

- (UIImage *)stretcheImage:(UIImage *)img
{
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.5];
}

- (void)awakeFromNib
{
    //设置录音按钮图片拉伸效果
    UIImage *image = [UIImage imageNamed:@""];
    UIImage *imageHL = [UIImage imageNamed:@""];
    image = [self stretcheImage:image];
    imageHL= [self stretcheImage:imageHL];
    
    [_recorderButton setBackgroundImage:image forState:UIControlStateNormal];
    [_recorderButton setBackgroundImage:imageHL forState:UIControlStateHighlighted];
    
    //实例化表情选择视图
    _emoteSelectorView = [[EmoteSelectorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 216)];
    _emoteSelectorView.delegate = self;
}

#pragma mark 设置按钮图像
- (void)setButton:(UIButton *)button imageName:(NSString *)imageName imageHLName:(NSString *)imageHLName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageHL = [UIImage imageNamed:imageHLName];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imageHL forState:UIControlStateHighlighted];
}

#pragma mark 声音\键盘切换
- (void)clickVoice:(UIButton *)button
{
    button.tag = !button.tag;
    
    _recorderButton.hidden = !button.tag;
    _inputText.hidden = button.tag;
    //1.判断当前输入状态，如果文本输入，显示按钮，隐藏键盘
    if (button.tag)
    {
        [_inputText resignFirstResponder];
        
        //切换按钮图标
        [self setButton:button imageName:@"ToolViewInputText" imageHLName:@"ToolViewInputTextHL"];
    }
    else
    {
        [self setButton:button imageName:@"ToolViewInputVoice" imageHLName:@"ToolViewInputVoiceHL"];

        [_inputText becomeFirstResponder];
    }
}

#pragma mark 点击表情切换按钮
- (void)clickEmote:(UIButton *)button
{
    //如果当前正在录音，需要切换到文本状态
    if (!_recorderButton.hidden)
    {
        [self clickVoice:_voiceButton];
    }
    
    button.tag = !button.tag;
    //激活键盘
    [_inputText becomeFirstResponder];
    if (button.tag)
    {
        //2.判断当前按钮的状态，如果是输入文本，替换
        [_inputText setInputView:_emoteSelectorView];
        [self setButton:button imageName:@"ToolViewInputText" imageHLName:@"ToolViewInputTextHL"];
    }
    else
    {
        [_inputText setInputView:nil];
        [self setButton:button imageName:@"ToolViewEmotion" imageHLName:@"ToolViewEmotionHL"];
    }
    
    //刷新键盘的输入视图
    [_inputText reloadInputViews];
}

#pragma mark - EmoteSelector Delegate
- (void)emoteSelectorViewSelectEmoteString:(NSString *)emote
{
    NSMutableString *strM = [NSMutableString stringWithString:_inputText.text];
    [strM appendString:emote];
    _inputText.text = strM;
}

- (void)emoteSelectorViewRemoveChar
{
    NSString *str = _inputText.text;
    if (str.length!=0) {
        _inputText.text = [str substringToIndex:(str.length - 1)];
    }
}

@end
