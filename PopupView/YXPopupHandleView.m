//
//  YXPopupHandleView.m
//  DzhProjectiPhone
//
//  Created by DZH_Louis on 2017/3/29.
//  Copyright © 2017年 gw. All rights reserved.
//

#import "YXPopupHandleView.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>

static CGFloat kAlertMaxWidth = 280; //弹窗显示部分最大宽度
static CGFloat kContentMinHeight = 100;  //内容最低高度
static CGFloat kBtnHeight = 45;  //按钮默认高度
static CGFloat kContentLRSpace = 10; //默认内容左右边距
static CGFloat kMidSpace = 10; //默认中间间隔
static CGFloat kAlertBottomSpace = 20; //默认alert底部间隔
static CGFloat kContentFontSize = 15; //默认字体大小
static CGFloat kContentTextVerticalSpace = 5; //默认内容每行间隔
static CGFloat kContentFootViewHeight = 5; //默认内容footView高度
static CGFloat kCornerRadius = 12; //alert圆角弧度
@interface YXPopupHandleView ()<CAAnimationDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSAttributedString *titleAttrStr;
@property(nonatomic,retain)NSMutableArray <NSArray <NSAttributedString*>*>*contentItems;
@property(nonatomic,retain)NSMutableArray <NSAttributedString*>*btnItems;
@property(nonatomic,copy)void(^clickBtnAction)(NSInteger btnIndex);
@property(nonatomic,retain)NSMutableArray *contentItemsHeightArr;

@property(nonatomic,retain)UIImageView *mainBgView;
@property(nonatomic,retain)UIView *alertView;
@property(nonatomic,retain)UIImageView *alertBgView;
@property(nonatomic,retain)UITableView *contentTableView;
@property(nonatomic,retain)UITableView *btnTableView;
@property(nonatomic,retain)UIButton *closeBtn;

@end

@implementation YXPopupHandleView

- (void)dealloc
{
    self.contentItemsHeightArr = nil;
    self.closeBtnImage = nil;
    self.titleAttrStr = nil;
    self.titleColor = nil;
    self.btnColor = nil;
    self.contentItems = nil;
    self.btnItems = nil;
    self.clickBtnAction = nil;
    _selfSuperView = nil;
#ifdef MRC_PopupConfirmView
    [super dealloc];
#endif
}

- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action
{
    return  [self initWithTitle:titleAttrStr contentItems:contentItems buttonItems:btnItems clickBtnAction:action delegate:nil];
}

- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems delegate:(id)delegate
{
    return  [self initWithTitle:titleAttrStr contentItems:contentItems buttonItems:btnItems clickBtnAction:nil delegate:delegate];
}

- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action delegate:(id)delegate
{
    self = [super init];
    if (self) {
        [self initData];
        self.titleAttrStr = titleAttrStr;
        [self.contentItems addObjectsFromArray:contentItems];
        [self.btnItems addObjectsFromArray:btnItems];
        self.clickBtnAction = action;
        self.delegate = delegate;
    }
    return self;
}

- (void)initData
{
    _contentItemsHeightArr = [[NSMutableArray alloc]init];
    _contentItems = [[NSMutableArray alloc]init];
    _btnItems = [[NSMutableArray alloc]init];
    _titleColor = [UIColor blackColor];
    _btnColor = [UIColor blackColor];
    _alertBackgroundColor = [UIColor whiteColor];
    
    _btnSizeHeight =  kBtnHeight;
    _contentFontSize = kContentFontSize;
    _contentLRSpace = kContentLRSpace;
    _midSpace = kMidSpace;
    _contentTextVerticalSpace = kContentTextVerticalSpace;
    _contentFootViewHeight = kContentFootViewHeight;
    _contentTextAlignment = NSTextAlignmentLeft;
    _isNeedShowCloseBtn = NO;
    _isNeedShowAnimation = NO;
    _isNeedDismissAnimation = NO;
    _toHorizontalArrangementWhenTwoButtons = YES;
    _useSingleRow = YES;
    _isNeedTouchDismiss = YES;
    _isSeparateBtn = NO;
    _displayPosition = PopupHandleDisplayPositionDefault;
    _displayAnimationStyle = PopupHandleDisplayAnimationStyleDefault;
}

- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    self.frame = _selfSuperView.bounds;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    if (self.mainBgView) {
        [self.mainBgView removeFromSuperview];
        self.mainBgView = nil;
    }
    _mainBgView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _mainBgView.backgroundColor = [UIColor blackColor];
    _mainBgView.userInteractionEnabled = YES;
    _mainBgView.alpha = 0.3;
    [self addSubview:_mainBgView];
#ifdef MRC_PopupConfirmView
    [_mainBgView release];
#endif
    if (self.alertView) {
        [self.alertView removeFromSuperview];
        self.alertView = nil;
    }
    _alertView = [self createAlertView];
    if (self.alertBgView) {
        [self.alertBgView removeFromSuperview];
        self.alertBgView = nil;
    }
    _alertView.layer.shouldRasterize = YES;
    _alertView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    if (_displayPosition == PopupHandleDisplayPositionDefault) { //center
        _alertView.center = self.center;
    }
    else if (_displayPosition == PopupHandleDisplayPositionBottom)//bottom
    {
        _alertView.frame = CGRectMake((self.frame.size.width - CGRectGetWidth(_alertView.frame))/2, self.frame.size.height - CGRectGetHeight(_alertView.frame) - kAlertBottomSpace, CGRectGetWidth(_alertView.frame), CGRectGetHeight(_alertView.frame));
    }
    else //top
    {
        _alertView.frame = CGRectMake((self.frame.size.width - CGRectGetWidth(_alertView.frame))/2,kAlertBottomSpace, CGRectGetWidth(_alertView.frame), CGRectGetHeight(_alertView.frame));
    }
    [self addSubview:_alertView];
#ifdef MRC_PopupConfirmView
    [_alertView release];
#endif
}

- (void)closeBtnAction:(UIButton *)btn
{
    [self dismiss:self.isNeedDismissAnimation];
}

- (UIView *)createAlertView
{
    CGFloat yAxis = 0.0;
    CGFloat ySpace = 10;
    CGFloat aWidth = self.frame.size.width -  40;
    CGFloat maxWidth = aWidth;
    (aWidth > kAlertMaxWidth) ? (maxWidth = kAlertMaxWidth) : (maxWidth = aWidth);
    
    //    //按最大尺寸缩放
    //    (aWidth < kAlertMaxWidth) ? (maxWidth = self.frame.size.width -  20) : (maxWidth = aWidth);
    //    CGFloat scale = self.frame.size.width/320;
    //    _contentLRSpace *= scale;
    //    _midSpace *= scale;
    CGFloat maxHeight = self.frame.size.height - kAlertBottomSpace*2;
    //alertView
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, maxWidth, maxHeight)];
    alertView.userInteractionEnabled = YES;
    alertView.backgroundColor = [UIColor clearColor];
    alertView.layer.cornerRadius = kCornerRadius;
    alertView.layer.masksToBounds = YES;
    
    UIView *contentTableViewBg  = [[UIView alloc]initWithFrame:CGRectZero];
    contentTableViewBg.backgroundColor = _alertBackgroundColor ? _alertBackgroundColor :[UIColor whiteColor];
    contentTableViewBg.userInteractionEnabled = YES;
    contentTableViewBg.alpha = 0.95;
    [alertView addSubview:contentTableViewBg];
#ifdef MRC_PopupConfirmView
    [contentTableViewBg release];
#endif
    CGFloat titleHeight = 0;
    CGFloat closeBtnWidth = 30;
    if (_titleAttrStr && [_titleAttrStr isKindOfClass:[NSAttributedString class]] && _titleAttrStr.length > 0) {
        titleHeight = 40;
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(closeBtnWidth, ySpace, maxWidth - closeBtnWidth*2, titleHeight - ySpace)];
        titleLabel.textColor = _titleColor;
        titleLabel.attributedText = _titleAttrStr;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [contentTableViewBg addSubview:titleLabel];
#ifdef MRC_PopupConfirmView
        [titleLabel release];
#endif
        if (_isNeedShowCloseBtn) {
            _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _closeBtn.backgroundColor = [UIColor clearColor];
            _closeBtn.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), ySpace,closeBtnWidth, closeBtnWidth);
            [_closeBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
            [_closeBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            if (_closeBtnImage) {
                [_closeBtn setImage:_closeBtnImage forState:UIControlStateNormal];
            }
            else if (_closeBtnAttrStr && [_closeBtnAttrStr isKindOfClass:[NSAttributedString class]])
            {
                [_closeBtn setAttributedTitle:_closeBtnAttrStr forState:UIControlStateNormal];
            }
            else{
                [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
            }
            _closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;  //对齐方式
            _closeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_closeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [contentTableViewBg addSubview:_closeBtn];
        }
        yAxis += titleHeight;
    }
    titleHeight += _contentTextVerticalSpace;
    yAxis += _contentTextVerticalSpace;
    
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTableView.backgroundColor = [UIColor clearColor];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    //  _contentTableView.bounces = NO;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contentTableViewBg addSubview:_contentTableView];
    if ([_contentTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_contentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
#ifdef MRC_PopupConfirmView
    [_contentTableView release];
#endif
    
    UIView *btnTableViewBg  = [[UIView alloc]initWithFrame:CGRectZero];
    btnTableViewBg.backgroundColor = _alertBackgroundColor ? _alertBackgroundColor :[UIColor whiteColor];
    btnTableViewBg.userInteractionEnabled = YES;
    btnTableViewBg.alpha = 0.95;
    [alertView addSubview:btnTableViewBg];
#ifdef MRC_PopupConfirmView
    [btnTableViewBg release];
#endif
    if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2)) {
        _btnTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _btnTableView.backgroundColor = [UIColor clearColor];
        _btnTableView.dataSource = self;
        _btnTableView.delegate = self;
        _btnTableView.bounces = NO;
        [btnTableViewBg addSubview:_btnTableView];
#ifdef MRC_PopupConfirmView
        [_btnTableView release];
#endif
        if ([_btnTableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [_btnTableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    CGFloat sumHeight = 0.0;
    CGFloat lrSpace = _contentLRSpace;
    for (NSArray *subArr in self.contentItems) {
        CGFloat mHeight = 0.0;
        CGFloat cellWidth = (maxWidth - lrSpace*2);
        if (subArr.count == 2)
        {
            cellWidth = (maxWidth - _midSpace - lrSpace*2)/2;
        }
        else if (subArr.count == 3)
        {
            cellWidth = (maxWidth - _midSpace*2 - lrSpace*2)/3;
        }
        BOOL useSingle = _useSingleRow && (subArr.count == 2 || subArr.count == 3);  //两条并排才使用,缩放
        for (NSAttributedString *aStr in subArr) {
            NSString  *str = @"";
            UIFont *strFont = [UIFont systemFontOfSize:_contentFontSize];
            if (aStr && [aStr isKindOfClass:[NSAttributedString class]] && aStr.length > 0)
            {
                str = aStr.string;
                NSRange attrRange = NSMakeRange(0, str.length);
                NSDictionary *attrDic = [aStr attributesAtIndex:0 effectiveRange:&attrRange];
                UIFont *font = [attrDic objectForKey:NSFontAttributeName];
                if (font) {
                    strFont = font;
                }
            }
            CGSize tempSize = CGSizeZero;
            if (useSingle) {
                tempSize = CGSizeMake(cellWidth, _contentFontSize + 2);
            }
            else
            {
                tempSize = [self stringBoundingRectWithSize:CGSizeMake(cellWidth, MAXFLOAT) withFont:strFont withDescription:str];
            }
            
            if (tempSize.height > mHeight) {
                mHeight = tempSize.height;
            }
        }
        [self.contentItemsHeightArr addObject:[NSNumber numberWithFloat:mHeight + _contentTextVerticalSpace]];
        sumHeight += mHeight + _contentTextVerticalSpace;
    }
    sumHeight += _contentFootViewHeight;
    UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,maxWidth, _contentFootViewHeight)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    _contentTableView.tableFooterView = tableFooterView;
#ifdef MRC_PopupConfirmView
    [tableFooterView release];
#endif
    CGFloat separateBtnSpace = 0.0;
    if (_isSeparateBtn) {
        contentTableViewBg.layer.cornerRadius = kCornerRadius;
        contentTableViewBg.layer.masksToBounds = YES;
        btnTableViewBg.layer.cornerRadius = kCornerRadius;
        btnTableViewBg.layer.masksToBounds = YES;
        separateBtnSpace = 10;
    }
    CGFloat btnTableViewHeight = (_toHorizontalArrangementWhenTwoButtons && self.btnItems.count == 2) ? _btnSizeHeight + separateBtnSpace : (self.btnItems.count * _btnSizeHeight + separateBtnSpace); //两个按钮横向排列
    CGFloat contentMinHeight = (sumHeight > kContentMinHeight) ?  kContentMinHeight : sumHeight;
    if (btnTableViewHeight + contentMinHeight > maxHeight - titleHeight) {
        btnTableViewHeight = ((int)((maxHeight -titleHeight - contentMinHeight)/_btnSizeHeight))*_btnSizeHeight;
    }
    CGFloat contentTableViewHeight = maxHeight - btnTableViewHeight - titleHeight;
    if (contentTableViewHeight > sumHeight) {
        contentTableViewHeight = sumHeight;
    }
    contentTableViewBg.frame = CGRectMake(0,0, maxWidth, yAxis + contentTableViewHeight);
    _contentTableView.frame = CGRectMake(0,yAxis, maxWidth, contentTableViewHeight);
    yAxis += contentTableViewHeight + 0.5;
    CALayer *lineLayer2 = [CALayer layer];
    lineLayer2.frame = CGRectMake(0, yAxis - 0.5,maxWidth, 0.5);
    lineLayer2.backgroundColor = [UIColor lightGrayColor].CGColor;
    [alertView.layer addSublayer:lineLayer2];
    
    btnTableViewBg.frame = CGRectMake(0,yAxis + separateBtnSpace, maxWidth, btnTableViewHeight - separateBtnSpace);
    if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2)) {
        _btnTableView.frame = CGRectMake(0,0, maxWidth, btnTableViewHeight - separateBtnSpace);
    }
    else
    {
        for (int i = 0; i < _btnItems.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake((maxWidth/2 + 0.25)*i, 0, maxWidth/2 - 0.25, btnTableViewHeight - separateBtnSpace);
            btn.tag = i;
            NSAttributedString *btnAStr = _btnItems[i];
            if (btnAStr && [btnAStr isKindOfClass:[NSAttributedString class]] && btnAStr.length > 0){
                [btn setAttributedTitle:btnAStr forState:UIControlStateNormal];
            }
            [btn setTitleColor:_btnColor forState:UIControlStateNormal];
            UIImage *bgImage = [self imageWithColor:[UIColor lightGrayColor] size:btn.frame.size alpha:0.5];
            [btn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(tapBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [btnTableViewBg addSubview:btn];
        }
        CALayer *lineLayer3 = [CALayer layer];
        lineLayer3.frame = CGRectMake((maxWidth/2 - 0.25), 0,0.5, btnTableViewHeight);
        lineLayer3.backgroundColor = [UIColor lightGrayColor].CGColor;
        [btnTableViewBg.layer addSublayer:lineLayer3];
    }
    
    yAxis += btnTableViewHeight;
    alertView.frame = CGRectMake(0, 0, maxWidth, yAxis);
    return alertView;
}

- (void)reloadTableViewData
{
    [_contentTableView reloadData];
    if (!(_toHorizontalArrangementWhenTwoButtons && _btnItems.count == 2))
    {
        [_btnTableView reloadData];
    }
}

+ (void)removeAllPopupHandleViewFromWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] delegate].window;
    [self removeAllPopupHandleViewFromView:keyWindow];
}

+ (void)removeAllPopupHandleViewFromView:(UIView *)superView
{
    for (UIView *v in superView.subviews) {
        if ([v isKindOfClass:[YXPopupHandleView class]]) {
            [v removeFromSuperview];
        }
    }
}

- (void)showInWindow
{
    [self showInWindow:_isNeedShowAnimation withDismissAnimation:_isNeedDismissAnimation];
}

- (void)showInWindow:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] delegate].window;
    [self showInView:keyWindow animated:animated withDismissAnimation:dismissAnimation];
}

- (void)showInView:(UIView *)view;
{
    [self showInView:view animated:_isNeedShowAnimation withDismissAnimation:_isNeedDismissAnimation];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation
{
    self.isNeedShowAnimation = animated;
    self.isNeedDismissAnimation = dismissAnimation;
    _selfSuperView = view;
    [self configUI];
    [self reloadTableViewData];
    //显示self到父视图
    [self removeFromSuperview];
    [_selfSuperView addSubview:self];
    if (animated) {
        [self showAnimation];
    }
    else
    {
        _isShow = YES;
    }
}

- (void)dismiss:(BOOL)animation
{
    if (animation) {
        [self dismissAnimation];
    }
    else
    {
        _isShow = NO;
        [self removeFromSuperview];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.isNeedTouchDismiss) {
        UITouch *touch = [event.allTouches anyObject];
        CGPoint point  = [touch locationInView:_selfSuperView];
        if (self.isShow && !CGRectContainsPoint(self.alertView.frame, point))
        {
            [self dismiss:self.isNeedDismissAnimation];
        }
    }
}

- (void)tapBtnAction:(UIButton *)btn
{
    [self tapAction:btn.tag];
}

- (void)tapAction:(NSInteger )index
{
    BOOL isBlock = NO;
    if (self.clickBtnAction) {
        isBlock = YES;
        self.clickBtnAction(index);
    }
    if (!isBlock && self.delegate && malloc_zone_from_ptr((__bridge const void *)(self.delegate)) && [self.delegate respondsToSelector:@selector(popupHandleView:clickedButtonAtIndex:)]) {
        [self.delegate popupHandleView:self clickedButtonAtIndex:index];
    }
    [self dismiss:self.isNeedDismissAnimation];
}

#pragma mark--  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _contentTableView) {
        return self.contentItems.count;
    }
    else
    {
        return self.btnItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _contentTableView) {
        static NSString *cellID = @"PopupHandleItemCell";
        PopupHandleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[PopupHandleItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.cellWidth = tableView.frame.size.width;
            cell.itemFont = [UIFont systemFontOfSize:_contentFontSize];
            cell.contentLRSpace = _contentLRSpace;
            cell.midSpace = _midSpace;
            cell.contentTextAlignment = self.contentTextAlignment;
        }
        if (self.contentItemsHeightArr.count > indexPath.row) {
            cell.cellHeight = [self.contentItemsHeightArr[indexPath.row] floatValue];
        }
        [cell fillItemsData:self.contentItems[indexPath.row]];
        return cell;
    }
    else
    {
        static NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
                [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
                [cell setPreservesSuperviewLayoutMargins:NO];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = _btnColor;
        }
        NSAttributedString *btnTextAttr = self.btnItems[indexPath.row];
        if (![btnTextAttr isKindOfClass:[NSAttributedString class]]) {
            btnTextAttr = [[NSAttributedString alloc]initWithString:@""];
        }
        cell.textLabel.attributedText = btnTextAttr;
        return cell;
    }
}

#pragma mark--  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _contentTableView) {
        CGFloat height = 0.0;
        if (self.contentItemsHeightArr.count > indexPath.row) {
            height = [self.contentItemsHeightArr[indexPath.row] floatValue];
        }
        return height;
    }
    else
    {
        return _btnSizeHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _btnTableView) {
        [self tapAction:indexPath.row];
    }
}

#pragma mark -- Animation
- (void)showAnimation  //仿UIAlertView动画效果
{
    if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleDefault) {
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        popAnimation.duration = 0.4;
        popAnimation.delegate=self;
        popAnimation.removedOnCompletion = NO;
        popAnimation.fillMode = kCAFillModeForwards;
        popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
        popAnimation.timingFunctions = @[
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.alertView.layer addAnimation:popAnimation forKey:@"showAnimation"];
    }
    else if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleActionSheet)
    {
        CABasicAnimation *actionSheetAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        actionSheetAnimation.duration = 0.4;
        actionSheetAnimation.fromValue = @(CGRectGetMaxY(self.frame) + _alertView.layer.position.y);
        actionSheetAnimation.toValue = @(_alertView.layer.position.y);
        actionSheetAnimation.delegate=self;
        actionSheetAnimation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        actionSheetAnimation.removedOnCompletion = NO;
        actionSheetAnimation.fillMode = kCAFillModeForwards;
        [self.alertView.layer addAnimation:actionSheetAnimation forKey:@"showAnimation"];
    }
    else if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleNotice)
    {
        CABasicAnimation *actionSheetAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        actionSheetAnimation.duration = 0.4;
        actionSheetAnimation.fromValue = @( - _alertView.layer.position.y);
        actionSheetAnimation.toValue = @(_alertView.layer.position.y);
        actionSheetAnimation.delegate=self;
        actionSheetAnimation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        actionSheetAnimation.removedOnCompletion = NO;
        actionSheetAnimation.fillMode = kCAFillModeForwards;
        [self.alertView.layer addAnimation:actionSheetAnimation forKey:@"showAnimation"];
    }
}

- (void)dismissAnimation
{
    CABasicAnimation *dismissAnimation = [CABasicAnimation animation];
    dismissAnimation.delegate = self;
    dismissAnimation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    dismissAnimation.removedOnCompletion = NO;
    dismissAnimation.fillMode = kCAFillModeForwards;
    if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleDefault) {
        dismissAnimation.keyPath = @"transform.scale";
        dismissAnimation.duration = 0.1;
        dismissAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        dismissAnimation.toValue = [NSNumber numberWithFloat:0];
    }
    else if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleActionSheet)
    {
        dismissAnimation.keyPath = @"position.y";
        dismissAnimation.duration = _displayPosition == PopupHandleDisplayPositionBottom ? 0.2 : 0.4;
        dismissAnimation.fromValue = @(_alertView.layer.position.y);
        dismissAnimation.toValue = @(CGRectGetMaxY(self.frame) + _alertView.layer.position.y);
    }
    else if (_displayAnimationStyle == PopupHandleDisplayAnimationStyleNotice)
    {
        dismissAnimation.keyPath = @"position.y";
        dismissAnimation.duration = _displayPosition == PopupHandleDisplayPositionTop ? 0.2 : 0.4;
        dismissAnimation.fromValue = @(_alertView.layer.position.y);
        dismissAnimation.toValue = @(- _alertView.layer.position.y);
    }
    [self.alertView.layer addAnimation:dismissAnimation forKey:@"dismissAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag //动画代理
{
    if (anim == [self.alertView.layer animationForKey:@"showAnimation"])
    {
        [self.alertView.layer removeAnimationForKey:@"showAnimation"];
        _isShow = YES;
    }
    else if(anim ==[self.alertView.layer animationForKey:@"dismissAnimation"])
    {
        [self.alertView.layer removeAnimationForKey:@"dismissAnimation"];
        _isShow = NO;
        [self removeFromSuperview];
    }
}

#pragma mark -- Util
//计算字符串尺寸
- (CGSize)stringBoundingRectWithSize:(CGSize)size withFont:(UIFont *)font withDescription:(NSString *)text
{
    CGSize s = CGSizeMake(size.width, size.height);
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize retSize = [text boundingRectWithSize:s    //该方法支持 ios 7.0以上系统
                                        options:
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return CGSizeMake(retSize.width, retSize.height);
}
//颜色转图片
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat )alpha
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    rect.size = size;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context, alpha);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

#pragma mark -- PopupHandleItemCell;
@interface PopupHandleItemCell()

@property(nonatomic,retain)UILabel *itemLabelOne;
@property(nonatomic,retain)UILabel *itemLabelTwo;
@property(nonatomic,retain)UILabel *itemLabelThree;

@end

@implementation PopupHandleItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self respondsToSelector:@selector(setLayoutMargins:)]){
            [self setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [self setPreservesSuperviewLayoutMargins:NO];
        }
        self.backgroundColor = [UIColor clearColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    _itemLabelOne = [[UILabel alloc]initWithFrame:CGRectZero];
    _itemLabelOne.textColor = [UIColor grayColor];
    _itemLabelOne.adjustsFontSizeToFitWidth = YES;
    _itemLabelOne.textAlignment = _contentTextAlignment;
    _itemLabelOne.numberOfLines = 0;
    _itemLabelOne.backgroundColor = [UIColor clearColor];
    [self addSubview:_itemLabelOne];
#ifdef MRC_PopupConfirmView
    [_itemLabelOne release];
#endif
    _itemLabelTwo = [[UILabel alloc]initWithFrame:CGRectZero];
    _itemLabelTwo.textColor = [UIColor grayColor];
    _itemLabelTwo.textAlignment = _contentTextAlignment;
    _itemLabelTwo.adjustsFontSizeToFitWidth = YES;
    _itemLabelTwo.numberOfLines = 0;
    _itemLabelTwo.backgroundColor = [UIColor clearColor];
    [self addSubview:_itemLabelTwo];
#ifdef MRC_PopupConfirmView
    [_itemLabelTwo release];
#endif
    _itemLabelThree = [[UILabel alloc]initWithFrame:CGRectZero];
    _itemLabelThree.textColor = [UIColor grayColor];
    _itemLabelThree.textAlignment = _contentTextAlignment;
    _itemLabelThree.adjustsFontSizeToFitWidth = YES;
    _itemLabelThree.numberOfLines = 0;
    _itemLabelThree.backgroundColor = [UIColor clearColor];
    [self addSubview:_itemLabelThree];
#ifdef MRC_PopupConfirmView
    [_itemLabelThree release];
#endif
}

- (void)setContentTextAlignment:(NSTextAlignment)contentTextAlignment
{
    objc_setAssociatedObject(self, @selector(contentTextAlignment), @(contentTextAlignment), OBJC_ASSOCIATION_ASSIGN);
    _itemLabelOne.textAlignment = _contentTextAlignment;
    _itemLabelTwo.textAlignment = _contentTextAlignment;
    _itemLabelThree.textAlignment = _contentTextAlignment;
}

- (void)setItemFont:(UIFont *)itemFont
{
    objc_setAssociatedObject(self, @selector(itemFont), itemFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _itemLabelOne.font = itemFont ? itemFont : [UIFont systemFontOfSize: kContentFontSize];
    _itemLabelTwo.font = itemFont ? itemFont : [UIFont systemFontOfSize: kContentFontSize];
    _itemLabelThree.font = itemFont ? itemFont : [UIFont systemFontOfSize: kContentFontSize];
}

- (void)fillItemsData:(NSArray *)itemsArr
{
    _itemLabelOne.attributedText = nil;
    _itemLabelTwo.attributedText = nil;
    _itemLabelThree.attributedText = nil;
    _itemLabelOne.frame = CGRectZero;
    _itemLabelTwo.frame = CGRectZero;
    _itemLabelThree.frame = CGRectZero;
    if (!itemsArr || itemsArr.count <= 0) {return;}
    NSInteger count = itemsArr.count;
    CGFloat lrSpace = _contentLRSpace;
    CGFloat width =(_cellWidth - _midSpace*(count -1) - lrSpace*2)/count;
    for (int i = 0; i < itemsArr.count; i++) {
        NSAttributedString *attrStr = itemsArr[i];
        if (attrStr && [attrStr isKindOfClass:[NSAttributedString class]] && attrStr.length > 0)
        {
            UIFont *strFont = _itemFont ? _itemFont : [UIFont systemFontOfSize: kContentFontSize];
            NSRange attrRange = NSMakeRange(0, attrStr.length);
            NSDictionary *attrDic = [attrStr attributesAtIndex:0 effectiveRange:&attrRange];
            UIFont *font = [attrDic objectForKey:NSFontAttributeName];
            if (font) {
                strFont = font;
            }
            NSDictionary *attribute = @{NSFontAttributeName: strFont};
            CGSize size = [attrStr.string boundingRectWithSize:CGSizeMake(width, _cellHeight)     //该方法支持 ios 7.0以上系统
                                                       options:
                           NSStringDrawingTruncatesLastVisibleLine |
                           NSStringDrawingUsesLineFragmentOrigin |
                           NSStringDrawingUsesFontLeading
                                                    attributes:attribute
                                                       context:nil].size;
            if (i == 0) {
                if (attrStr && [attrStr isKindOfClass:[NSAttributedString class]] && attrStr.length > 0){
                    _itemLabelOne.attributedText = attrStr;
                }
                _itemLabelOne.frame = CGRectMake(lrSpace, 0, width, size.height);
            }
            else if (i == 1)
            {
                if (attrStr && [attrStr isKindOfClass:[NSAttributedString class]] && attrStr.length > 0){
                    _itemLabelTwo.attributedText = attrStr;
                }
                _itemLabelTwo.frame = CGRectMake(width+_midSpace+lrSpace, 0, width, size.height);
            }
            else if (i == 2)
            {
                if (attrStr && [attrStr isKindOfClass:[NSAttributedString class]] && attrStr.length > 0){
                    _itemLabelThree.attributedText = attrStr;
                }
                _itemLabelThree.frame = CGRectMake(width*2+_midSpace*2+lrSpace, 0, width, size.height);
            }
        }
    }
}

@end
