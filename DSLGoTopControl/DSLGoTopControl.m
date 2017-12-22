//
//  DSLGoTopControl.m
//  
//
//  Created by 邓顺来 on 2017/12/22.
//  Copyright © 2017年 邓顺来. All rights reserved.
//

#import "DSLGoTopControl.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DSLGoTopControl ()

@property (strong, nonatomic) UIImageView *topIcon;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (assign, nonatomic) CGPoint centerInSuper;
@property (strong, nonatomic) NSArray *hConstraints;
@property (assign, nonatomic) BOOL isOut;

@end

@implementation DSLGoTopControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setup];
    }
    return self;
}

- (void)setupUI {
    _topIcon = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv.image = [UIImage imageNamed:@"arrow_top"];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.clipsToBounds = YES;
        iv;
    });
    _topLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = UIColorFromRGB(0x333333);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self addSubview:_topIcon];
    [self addSubview:_topLabel];
    
    _topIcon.translatesAutoresizingMaskIntoConstraints = NO;
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topIcon
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topIcon
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topIcon
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:3]];
}

- (void)setup {
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 1;
    self.layer.masksToBounds = NO;
    
    _topLabel.text = @"顶部";
    _edge = UIEdgeInsetsMake(0, 0, 15, 15);
    _size = 45;
    _moveStyle = DSLGoTopControlMoveStyleTranslate;
    _moveDuration = 0.35;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupAnimator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        [self setupGesture];
    }
}

- (void)setupGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - Action

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self.superview];
    //NSLog(@"%@",NSStringFromCGPoint(location));
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            [_animator removeAllBehaviors];
            UIOffset offset = UIOffsetMake(location.x - self.center.x, location.y - self.center.y);
            UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc] initWithItem:self offsetFromCenter:offset attachedToAnchor:location];
            [_animator addBehavior:attach];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (_animator.behaviors.count) {
                UIAttachmentBehavior *attach = _animator.behaviors[0];
                attach.anchorPoint = location;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [_animator removeAllBehaviors];
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self snapToPoint:self.center];
            snap.damping = 0.8;
            [_animator addBehavior:snap];
        }
            break;
        default:
            break;
    }
}

#pragma mark - API

- (void)placeIn:(UIView *)view {
    [view addSubview:self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(size)]-(edge)-|"
                                                            options:0
                                                            metrics:@{@"size":@(_size),@"edge":@(_edge.right)}
                                                              views:NSDictionaryOfVariableBindings(self)];
    [view addConstraints:_hConstraints];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(size)]-(edge)-|"
                                                                 options:0
                                                                 metrics:@{@"size":@(_size),@"edge":@(_edge.bottom)}
                                                                   views:NSDictionaryOfVariableBindings(self)]];
    self.layer.cornerRadius = _size / 2.0;
    [self setupAnimator];
}

- (void)moveOut {
    if (!_isOut) {
        [_animator removeAllBehaviors];
        if (_moveStyle == DSLGoTopControlMoveStyleTranslate) {
            [self.superview removeConstraints:_hConstraints];
            _hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(size)]-(edge)-|"
                                                                    options:0
                                                                    metrics:@{@"size":@(_size),@"edge":@(-_edge.right-_size)}
                                                                      views:NSDictionaryOfVariableBindings(self)];
            [self.superview addConstraints:_hConstraints];
            [UIView animateWithDuration:_moveDuration animations:^{
                [self.superview layoutIfNeeded];
            }];
        } else if (_moveStyle == DSLGoTopControlMoveStyleAlpha) {
            [UIView animateWithDuration:_moveDuration animations:^{
                self.alpha = 0;
            }];
        }
        _isOut = YES;
    }
}

- (void)moveInto {
    if (_isOut) {
        [_animator removeAllBehaviors];
        if (_moveStyle == DSLGoTopControlMoveStyleTranslate) {
            [self.superview removeConstraints:_hConstraints];
            _hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(size)]-(edge)-|"
                                                                    options:0
                                                                    metrics:@{@"size":@(_size),@"edge":@(_edge.right)}
                                                                      views:NSDictionaryOfVariableBindings(self)];
            [self.superview addConstraints:_hConstraints];
            [UIView animateWithDuration:_moveDuration animations:^{
                [self.superview layoutIfNeeded];
            }];
        } else if (_moveStyle == DSLGoTopControlMoveStyleAlpha) {
            [UIView animateWithDuration:_moveDuration animations:^{
                self.alpha = 1;
            }];
        }
        _isOut = NO;
    }
}

@end
