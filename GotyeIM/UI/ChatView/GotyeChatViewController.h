//
//  GotyeChatViewController.h
//  GotyeIM
//
//  Created by Peter on 14-10-16.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"

#import <AVFoundation/AVFoundation.h>

@interface GotyeChatViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *chatView;
@property (strong, nonatomic) IBOutlet UIView *inputView;

//BQMM集成  更换控件，请修改相应的.xib
@property (strong, nonatomic) IBOutlet UITextView * textInput;

@property (strong, nonatomic) IBOutlet UIButton *buttonVoice;
@property (strong, nonatomic) IBOutlet UIButton *buttonWrite;

@property (strong, nonatomic) IBOutlet UIButton *buttonSpeak;

@property (strong, nonatomic) IBOutlet UIButton *buttonRealTime;

@property (strong, nonatomic) IBOutlet UIView *realtimeStartView;
@property (strong, nonatomic) IBOutlet UILabel *labelRealTimeStart;

@property (strong, nonatomic) IBOutlet UIView *speakingView;

//BQMM集成  添加表情等按钮，请修改相应的.xib
@property (strong, nonatomic) IBOutlet UIButton *buttonFace;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *inputViewBottomLayout;

-(id)initWithTarget:(GotyeOCChatTarget*)target;

@end
