//
//  ViewController.m
//  YXPopupHandleViewDemo
//
//  Created by DZH_Louis on 2017/4/28.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#import "ViewController.h"
#import "YXPopupHandleView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)UITableView *mTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _mTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    [self.view addSubview:_mTableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopupHandleDisplayPosition position = PopupHandleDisplayPositionDefault;
    PopupHandleDisplayAnimationStyle style = PopupHandleDisplayAnimationStyleDefault;
    BOOL isNeedSeparateBtn = NO;
    BOOL isNeedCloseBtn = NO;
    NSString *titleStr = @"提示信息";
    NSArray <NSArray<NSString*>*>*textArr =@[@[@"测试数据第一列测试数据第一列测试数据第一列测试数据第一列",@"这个测试数试数居很长这个测居很长"],@[@"测试数据第二列测试数据第二列测试数据第二列测试数据第二列"]];
    NSArray *btnStrArr = @[@"取消",@"确定"];
    if (indexPath.row == 0) {
        isNeedCloseBtn = YES;
        btnStrArr = nil;
        position = PopupHandleDisplayPositionTop;
        style = PopupHandleDisplayAnimationStyleNotice;
    }
    else if (indexPath.row == 1)
    {
        textArr =@[@[@"测试数据第一列测第一列"],@[@"测试数据第二列测试数据第二列测试数据第二列测试数据第二列"]];
        btnStrArr = @[@"第一个按钮",@"第二个按钮",@"第三个按钮",@"第四个按钮",@"第五个按钮"];
        isNeedSeparateBtn = YES;
        position = PopupHandleDisplayPositionBottom;
        style = PopupHandleDisplayAnimationStyleActionSheet;
    }
    
    NSMutableArray *contentItmes = [NSMutableArray array];
    for (NSArray *subArr in textArr) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSString *str in subArr) {
            NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:str attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:15]}] ;
            [tempArr addObject:attrStr];
        }
        [contentItmes addObject:tempArr];
    }

    NSMutableArray *btnAttrStrArr = [NSMutableArray array];
    for (NSString *btnStr in btnStrArr) {
        NSAttributedString *btnAttrStr = [[NSAttributedString alloc]initWithString:btnStr attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        [btnAttrStrArr addObject:btnAttrStr];
    }
    
    NSAttributedString *titleAttrStr = nil;
    if (titleStr) {
        titleAttrStr = [[NSAttributedString alloc]initWithString:titleStr attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:18]}];
    }
    YXPopupHandleView *popupHandleView = [[YXPopupHandleView alloc]initWithTitle:titleAttrStr contentItems:contentItmes ? contentItmes : nil buttonItems:btnAttrStrArr.count ? btnAttrStrArr : nil clickBtnAction:^(NSInteger index){
        NSLog(@"%ld",index);
    }];
    popupHandleView.contentTextAlignment = NSTextAlignmentLeft;
    popupHandleView.useSingleRow = NO;
    popupHandleView.isNeedShowCloseBtn = isNeedCloseBtn;
    popupHandleView.displayPosition = position;
    popupHandleView.displayAnimationStyle = style;
    popupHandleView.isSeparateBtn = isNeedSeparateBtn;
    [popupHandleView showInWindow:YES withDismissAnimation:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld条",indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
