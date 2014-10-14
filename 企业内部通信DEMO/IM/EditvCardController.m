//
//  EditvCardController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-13.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "EditvCardController.h"
#import "NSString+Helper.h"

@interface EditvCardController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *contentText;

@end

@implementation EditvCardController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _contentText.text = _contentLabel.text;
    
    [_contentText becomeFirstResponder];
}

- (IBAction)save:(id)sender
{
    _contentLabel.text = [_contentText.text trimString];
    
    [_delegate editvCardControllerDidFinished];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 文本框代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self save:nil];
    return YES;
}
@end
