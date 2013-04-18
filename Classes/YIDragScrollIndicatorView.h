//
//  YIDragScrollIndicatorView.h
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// NOTE: this class is just a simple CAShapeLayer wrapper without any drawings on init
@interface YIDragScrollIndicatorView : UIView

@property (nonatomic, strong, readonly) CAShapeLayer* layer;

@property (nonatomic, strong) UIBezierPath* bezierPath;

@property (nonatomic) UIScrollViewIndicatorStyle indicatorStyle;

- (id)initWithFrame:(CGRect)frame indicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle;

- (void)animateFromBezierPath:(UIBezierPath*)fromBezierPath
                 toBezierPath:(UIBezierPath*)toBezierPath
                     duration:(NSTimeInterval)duration;

@end
