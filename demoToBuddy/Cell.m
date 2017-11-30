//
//  Cell.m
//  demoToBuddy
//
//  Created by Chan on 2017/5/4.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "Cell.h"
#import "DataHelper.h"
#define kGap 10
#define kButtonW 80
#define kButtonH  40

@interface Cell (){
    UILabel *_title;
    ContainerView *_containView;
}

@end
@implementation Cell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _title = [[UILabel alloc] initWithFrame:CGRectMake(kGap, 0, [UIScreen mainScreen].bounds.size.width - kGap - 50, 30)];
        _title.userInteractionEnabled = YES;
        _title.font = [UIFont systemFontOfSize:14];
        _title.textColor = [UIColor blueColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
        [_title addGestureRecognizer:tap];
        [self addSubview:_title];
        //箭头
        _arrow = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrow.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, _title.frame.origin.y, 30, 30);
        [_arrow setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
        [_arrow setImage:[UIImage imageNamed:@"2"] forState:UIControlStateSelected];
        [self addSubview:_arrow];
        
        //装按钮的containerView
        _containView = [[ContainerView alloc] init];
        [self addSubview:_containView];
    }
    return self;
}

#pragma mark --private Method
- (void)buttonAction:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        _arrow.selected = !_arrow.selected;
        if (_complete) {
            _complete(_model);
        }
    }
}

-(void)setCellWithData:(Model *)model {
    _model = model;
    _title.text = model.title;
    [_containView setWithDataSource:model.subTitles];
    if (model.expand) {
        _containView.hidden = NO;
    } else {
        _containView.hidden = YES;
    }
    _containView.complete = ^(NSString *contentStr) {
        _title.text =contentStr;
    };

}

///计算高度
+(CGFloat)getCellHeightWithModel:(Model *)model {
    if (model.expand) {
        CGFloat H = 0;
        CGFloat W= 0 ;
        int colum = 0;
        for (int i = 0; i < model.subTitles.count; i ++) {
            NSString *subStr = model.subTitles[i];
            W += [DataHelper widthWithString:subStr font:[UIFont systemFontOfSize:10]] +kGap;
            if (W +[DataHelper widthWithString:subStr font:[UIFont systemFontOfSize:10]] +kGap >=[UIScreen mainScreen].bounds.size.width) {
                colum ++;
                W = 0;
                continue;
            }
        }
        NSLog(@"%zd",colum + 1);
        H = (colum + 1) * (kGap + kButtonH);
        NSLog(@"%.2f",H);
        return H + 40;
    } else {
        return 40;
    }
}


@end

@implementation ContainerView

///容器View单独装按钮
- (void)setWithDataSource:(NSArray *)dataSource {
    _contentStr = [NSMutableString new];
    UIButton  *buttons[dataSource.count];
    for (int i = 0; i < dataSource.count; i ++) {
        buttons[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        buttons[i].frame = CGRectMake(i == 0 ? kGap :buttons[i - 1].right + kGap + [DataHelper widthWithString:dataSource[i] font:[UIFont systemFontOfSize:10]]>[UIScreen mainScreen].bounds.size.width ? kGap:buttons[i - 1].right + kGap,
                                       i == 0 ? kGap :buttons[i - 1].right + kGap + [DataHelper widthWithString:dataSource[i] font:[UIFont systemFontOfSize:10]]>[UIScreen mainScreen].bounds.size.width ?buttons[i -1].bottom + kGap : buttons[i-1].top,
                                       [DataHelper widthWithString:dataSource[i] font:[UIFont systemFontOfSize:10]], kButtonH);        [buttons[i] setTitle:dataSource[i] forState:UIControlStateNormal];
        buttons[i].backgroundColor = [UIColor whiteColor];
        buttons[i].layer.borderWidth = 0.5;
        buttons[i].clipsToBounds = YES;
        buttons[i].layer.cornerRadius = 4.0;
        buttons[i].layer.borderColor = [UIColor blackColor].CGColor;
        [buttons[i]  setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [buttons[i] setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        buttons[i].titleLabel.font = [UIFont systemFontOfSize:10];
        buttons[i].titleLabel.textAlignment = 1;
        [buttons[i] setBackgroundImage:[[self class] createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [buttons[i] setBackgroundImage:[[self class] createImageWithColor:[UIColor blackColor]] forState:UIControlStateSelected];

        [buttons[i] addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttons[i]];
    }
    CGFloat H = buttons[dataSource.count - 1].bottom + kGap;
    self.left = 0;
    self.height = H;
    self.width = [UIScreen mainScreen].bounds.size.width;
    self.top = 30;
}

- (void)buttonAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        button.selected = !button.selected;
        NSString *selectedStr = button.selected ? button.titleLabel.text :@"";
        [_contentStr appendString:selectedStr];
        if (!button.selected) {
            NSString *titleStr = button.titleLabel.text;
            [_contentStr replaceCharactersInRange:[_contentStr rangeOfString:titleStr] withString:@""];
        }
        NSLog(@"------>%@",_contentStr);
        if (_complete) {
            _complete(_contentStr);
        }
    }
}

+ (UIImage*) createImageWithColor:(UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
