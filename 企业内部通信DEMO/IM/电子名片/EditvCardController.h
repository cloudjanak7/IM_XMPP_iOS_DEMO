//
//  EditvCardController.h
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-13.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditvCardController;
@protocol EditvCardControllerDelegate <NSObject>

- (void)editvCardControllerDidFinished;

@end

@interface EditvCardController : UIViewController

@property (weak, nonatomic) id<EditvCardControllerDelegate> delegate;

@property (nonatomic, weak) UILabel *contentLabel;

@end
