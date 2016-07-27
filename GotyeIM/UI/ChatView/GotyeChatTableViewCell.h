//
//  GotyeChatTableViewCell.h
//  GotyeIM
//
//  Created by yangchuanshuai on 15/10/21.
//  Copyright © 2015年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DidSelectedCell)(id sender);

@interface GotyeChatTableViewCell : UITableViewCell

@property (nonatomic, copy) DidSelectedCell didSelectedCell;

@end
