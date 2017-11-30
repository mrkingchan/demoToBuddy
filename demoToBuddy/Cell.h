//
//  Cell.h
//  demoToBuddy
//
//  Created by Chan on 2017/5/4.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "UIView+Frame.h"
@interface Cell : UITableViewCell

@property(nonatomic,strong) UIButton *arrow;

+ (CGFloat)getCellHeightWithModel:(Model *)model;

- (void)setCellWithData:(id)model;

@property(nonatomic,strong) Model *model;

@property(nonatomic,copy)void (^complete)(Model *model);

@end

@interface ContainerView:UIView

- (void)setWithDataSource:(NSArray *)dataSource;

@property(nonatomic,copy)void (^complete)(NSString *contentStr);

@property(nonatomic,strong) NSMutableString *contentStr;

@end
