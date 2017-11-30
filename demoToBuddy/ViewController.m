//
//  ViewController.m
//  demoToBuddy
//
//  Created by Chan on 2017/5/4.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "Cell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    _dataArray = [NSMutableArray new];
    for (int i = 0; i < 10; i ++) {
        Model *model = [Model new];
        model.title = [NSString stringWithFormat:@"mrChan+++++%zd",i];
        model.expand = NO;
        model.subTitles = @[@"HFIUHG",@"GJGILHGILS",@"JHRILGHILGHAILGA",@"RURA",@"UJOLGG",@"URIOURW8GLYWGLHGSIHSHGUSHSHS",@"FJSOJIFHIUA"];
        [_dataArray addObject:model];
    }
    [self setUI];
}

///初始化UI
- (void)setUI {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

#pragma mark --UITableViewDataSource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kcellID = @"kcellID";
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:kcellID];
    if (!cell) {
        cell = [[Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kcellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellWithData:_dataArray[indexPath.row]];
    //点击cell
    cell.complete = ^(Model *model) {
        model.expand = !model.expand;
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        [_tableView reloadData];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [Cell getCellHeightWithModel:_dataArray[indexPath.row]];
}
@end
