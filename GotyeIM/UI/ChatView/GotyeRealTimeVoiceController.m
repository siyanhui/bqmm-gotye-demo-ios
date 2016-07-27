//
//  GotyeRealTimeVoiceController.m
//  GotyeIM
//
//  Created by Peter on 14-10-21.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeRealTimeVoiceController.h"
#import "GotyeOCAPI.h"
#import "GotyeUIUtil.h"

#define IconSize        50
#define IconGap         10

@interface GotyeRealTimeVoiceController () <GotyeOCDelegate>
{
    BOOL realtimeStart;
    BOOL isForeground;
}

@end

@implementation GotyeRealTimeVoiceController

@synthesize scrollViewUsers, labelSpeaker, imageSpeaking;

- (id)initWithRoomID:(unsigned)ID talkingID:(NSString *)userID
{
    self = [self init];
    if(self)
    {
        roomID = ID;
        talkingUserID = userID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification1:) name:@"Foreground" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(talkingUserID != nil)
        labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", talkingUserID];
    
    imageSpeaking.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"chat_realtime_speak_1"],
                                     [UIImage imageNamed:@"chat_realtime_speak_2"],
                                     [UIImage imageNamed:@"chat_realtime_speak_3"], nil];
    imageSpeaking.animationDuration = 1;
    
    isForeground = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    GotyeOCRoom* room = [GotyeOCRoom roomWithId:roomID];
    [GotyeOCAPI reqRoomMemberList:room pageIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
    
    [GotyeOCAPI stopTalk];
    
    [imageSpeaking stopAnimating];
    
    realtimeStart = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Dispose of any resources that can be recreated.
}

-(IBAction)speakButtonDown:(id)sender
{
}

-(IBAction)speakButtonUp:(id)sender
{
    if (isForeground) {
        if(realtimeStart)
        {
            [GotyeOCAPI stopTalk];
            
            [imageSpeaking stopAnimating];
            
            realtimeStart = NO;
        }
        else
        {
            if(talkingUserID == nil)
                [GotyeOCAPI stopPlay];
            
            GotyeOCRoom* room = [GotyeOCRoom roomWithId:roomID];
            [GotyeOCAPI startTalk:room mode:GotyeWhineModeDefault realtime:YES maxDuration:60*1000];
            
            labelSpeaker.text = [NSString stringWithFormat:@"抢麦中..."];
            
            realtimeStart = YES;
        }
    }else {
        
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            if(realtimeStart)
            {
                [GotyeOCAPI stopTalk];
                
                [imageSpeaking stopAnimating];
                
                realtimeStart = NO;
            }
            else
            {
                if(talkingUserID == nil)
                    [GotyeOCAPI stopPlay];
                
                GotyeOCRoom* room = [GotyeOCRoom roomWithId:roomID];
                [GotyeOCAPI startTalk:room mode:GotyeWhineModeDefault realtime:YES maxDuration:60*1000];
                
                labelSpeaker.text = [NSString stringWithFormat:@"抢麦中..."];
                
                realtimeStart = YES;
            }
            isForeground = YES;
        });
    }
}

- (void)resetHeadIcon:(NSInteger)headIconIndex
{
    UIButton *button = (UIButton*)[scrollViewUsers viewWithTag:headIconIndex + 1];
    GotyeOCUser* user = roomUserlist[headIconIndex];
    
    UIImage *headImage = [GotyeUIUtil getHeadImage:user.icon.path defaultIcon:@"head_icon_user"];
    
    [button setBackgroundImage:headImage forState:UIControlStateNormal];
}
#pragma mark 全局通知
- (void) notification1:(NSNotification *)notification
{
    isForeground = NO;
}

#pragma mark - Gotye UI delegates
-(void) onLogin:(GotyeStatusCode)code user:(GotyeOCUser*)user
{
    
}
- (void)onGetRoomMemberList:(GotyeStatusCode)code room:(GotyeOCRoom*)room pageIndex:(unsigned int)pageIndex curPageMemberList:(NSArray*)curPageMemberList allMemberList:(NSArray*)allMemberList
{
    roomUserlist = allMemberList;
    
    for(int i = 0; i<allMemberList.count; i++)
    {
        //GotyeOCUser* user = allMemberList[i];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(IconGap + (IconSize + IconGap) * i, IconGap, IconSize, IconSize)];
        button.tag = i + 1;
        
        [scrollViewUsers addSubview:button];
        
        [self resetHeadIcon:i];
    }
    
    scrollViewUsers.contentSize = CGSizeMake(roomUserlist.count * (IconSize + IconGap) + IconGap, IconSize + IconGap * 2);
}

- (void)onStartTalk:(GotyeStatusCode)code target:(GotyeOCChatTarget*)target realtime:(bool)realtime
{
    if(realtime && code == GotyeStatusCodeOK)
    {
        labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", [GotyeOCAPI getLoginUser].name];
        [imageSpeaking startAnimating];
    }
    else
    {
        labelSpeaker.text = [NSString stringWithFormat:@"抢麦失败"];
        
        realtimeStart = NO;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", [GotyeOCAPI getLoginUser].name];
        });
    }
}

- (void)onStopTalk:(GotyeStatusCode)code realtime:(bool)realtime message:(GotyeOCMessage*)message cancelSending:(bool *)cancelSending
{
    if(realtime)
    {
        talkingUserID = nil;
        labelSpeaker.text = @"";
        [imageSpeaking stopAnimating];
        
        realtimeStart = NO;
    }
}

- (void)onRealPlayStart:(GotyeStatusCode)code speaker:(GotyeOCUser*)speaker room:(GotyeOCRoom*)room
{
    talkingUserID = speaker.name;
    
    labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", talkingUserID];
}

- (void)onPlayStop
{
    talkingUserID = nil;
    labelSpeaker.text = @"";
}

@end
