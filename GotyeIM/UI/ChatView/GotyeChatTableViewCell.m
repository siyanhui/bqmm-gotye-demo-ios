//
//  GotyeChatTableViewCell.m
//  GotyeIM
//
//  Created by yangchuanshuai on 15/10/21.
//  Copyright © 2015年 Gotye. All rights reserved.
//

#import "GotyeChatTableViewCell.h"

@implementation GotyeChatTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)becomeFirstResponder {
    return YES;
}

- (void)test:(id)sender {
    if (self.didSelectedCell != nil) {
        self.didSelectedCell(sender);
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action ==@selector(test:)){
        
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
