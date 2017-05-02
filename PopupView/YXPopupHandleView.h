
#import <UIKit/UIKit.h>

#if __has_feature(objc_arc)  //arc模式
#else
#define MRC_PopupConfirmView
#endif

typedef NS_ENUM(NSInteger,PopupHandleDisplayAnimationStyle)  //显示的动画样式
{
    PopupHandleDisplayAnimationStyleDefault,   //alert效果
    PopupHandleDisplayAnimationStyleActionSheet, //ActionSheet
    PopupHandleDisplayAnimationStyleNotice //Notice
};

typedef NS_ENUM(NSInteger,PopupHandleDisplayPosition)  //显示的位置
{
    PopupHandleDisplayPositionDefault,   //Center
    PopupHandleDisplayPositionBottom, //Bottom
    PopupHandleDisplayPositionTop //Top
};

@protocol YXPopupHandleViewDelegate;
@interface YXPopupHandleView : UIView

@property(nonatomic,retain)UIImage *closeBtnImage;
@property(nonatomic,retain)NSAttributedString *closeBtnAttrStr;
@property(nonatomic,retain)UIColor *titleColor; //默认黑色
@property(nonatomic,retain)UIColor *btnColor; //默认黑色
@property(nonatomic,retain)UIColor *alertBackgroundColor; //默认白色

@property(nonatomic,assign)CGFloat alertViewWidth;
@property(nonatomic,assign)CGFloat contentFontSize; //默认15
@property(nonatomic,assign)CGFloat btnSizeHeight; //按钮高度默认45
@property(nonatomic,assign)CGFloat contentLRSpace; //内容左右边距,默认10
@property(nonatomic,assign)CGFloat midSpace; //中间边距,默认10
@property(nonatomic,assign)CGFloat contentTextVerticalSpace; //内容每行间隔,默认5
@property(nonatomic,assign)CGFloat contentFootViewHeight;

@property(nonatomic,assign)id<YXPopupHandleViewDelegate>delegate;
@property(nonatomic,assign)BOOL isNeedShowCloseBtn; //默认NO
@property(nonatomic,assign)BOOL isNeedShowAnimation;//默认NO
@property(nonatomic,assign)BOOL isNeedDismissAnimation;//默认NO
@property(nonatomic,assign)NSTextAlignment contentTextAlignment; //默认NSTextAlignmentLeft
@property(nonatomic,assign)BOOL toHorizontalArrangementWhenTwoButtons; //横向排列,当有两个按钮时,默认为YES
@property(nonatomic,assign)BOOL useSingleRow;  //使用单行显示每条内容,默认为YES
@property(nonatomic,assign)BOOL isNeedTouchDismiss;  //点击非alert区域自动消失,默认为YES
@property(nonatomic,assign)BOOL isSeparateBtn; //按钮分开的,参见系统actionSheet效果,默认为NO
@property(nonatomic,assign)PopupHandleDisplayAnimationStyle displayAnimationStyle;
@property(nonatomic,assign)PopupHandleDisplayPosition            displayPosition;

@property(nonatomic,assign,readonly)BOOL isShow;    //是否是显示状态
@property(nonatomic,assign,readonly)UIView *selfSuperView;

- (instancetype)initWithTitle:(NSAttributedString*)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action;

- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems delegate:(id)delegate;
/**
 初始化
 @param titleAttrStr 标题
 @param contentItems @[@[item1,item2],@[item3],@[item4,item5]....]  //数组内最多三个元素(目前支持)
 @param btnItems @[str1,str2,str3...]
 @param action 点击按钮事件
 @param delegate 代理
 @return 返回对象
 */
- (instancetype)initWithTitle:(NSAttributedString *)titleAttrStr contentItems:(NSArray <NSArray <NSAttributedString*>*>*)contentItems buttonItems:(NSArray <NSAttributedString*>*)btnItems clickBtnAction:(void(^)(NSInteger btnIndex))action delegate:(id)delegate;

+ (void)removeAllPopupHandleViewFromWindow; //移除所有在window上显示的popupHandleView
+ (void)removeAllPopupHandleViewFromView:(UIView *)superView; //移除所有在View上显示的popupHandleView
/**
 显示视图
 //在window上显示,消失时,务必手动移除,防止点击事件混乱
 //默认不需要弹出消失动画
 */
- (void)showInWindow;

/**
 显示视图
 @param animated 显示动画
 @param dismissAnimation 消失动画
 */
- (void)showInWindow:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation;
/**
 显示视图
 @param view SuperView
 //默认不需要弹出消失动画
 */
- (void)showInView:(UIView *)view;
/**
 显示视图
 @param view SuperView
 @param animated 是否需要弹出动画
 @param dismissAnimation 是否需要消失动画
 */
- (void)showInView:(UIView *)view animated:(BOOL)animated withDismissAnimation:(BOOL)dismissAnimation;
/**
 消失方法
 @param animation 是否需要消失动画
 */
- (void)dismiss:(BOOL)animation;

@end

@protocol YXPopupHandleViewDelegate <NSObject>
@optional
- (void)popupHandleView:(YXPopupHandleView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface PopupHandleItemCell : UITableViewCell

@property(nonatomic,assign)CGFloat cellWidth;
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,retain)UIFont *itemFont;
@property(nonatomic,assign)CGFloat contentLRSpace; //内容左右边距,默认10
@property(nonatomic,assign)CGFloat midSpace; //中间边距,默认10
@property(nonatomic,assign)NSTextAlignment contentTextAlignment;

- (void)fillItemsData:(NSArray *)itemsArr;

@end
