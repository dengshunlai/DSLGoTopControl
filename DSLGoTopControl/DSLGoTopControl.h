//
//  DSLGoTopControl.h
//
//
//  Created by 邓顺来 on 2017/12/22.
//  Copyright © 2017年 邓顺来. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSLGoTopControlMoveStyle) {
    DSLGoTopControlMoveStyleTranslate = 0,
    DSLGoTopControlMoveStyleAlpha,
};

@interface DSLGoTopControl : UIControl

/**
 控件离父视图边缘的距离，只有右下有效，默认(0,0,15,15)
 */
@property (assign, nonatomic) UIEdgeInsets edge;

/**
 控件宽高，默认45
 */
@property (assign, nonatomic) CGFloat size;

/**
 控件移出移入的动画类型，默认是平移
 */
@property (assign, nonatomic) DSLGoTopControlMoveStyle moveStyle;

/**
 动画持续时间，默认0.35
 */
@property (assign, nonatomic) CGFloat moveDuration;

/**
 放置控件
 
 @param view 父视图
 */
- (void)placeIn:(UIView *)view;

/**
 移出父视图
 */
- (void)moveOut;

/**
 回到初始位置
 */
- (void)moveInto;

@end

