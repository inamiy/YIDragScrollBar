//
//  YIDragScrollIndicatorView.m
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "YIDragScrollIndicatorView.h"

@implementation YIDragScrollIndicatorView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame indicatorStyle:UIScrollViewIndicatorStyleDefault];
}

- (id)initWithFrame:(CGRect)frame indicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.indicatorStyle = indicatorStyle;
        
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

#pragma mark -

#pragma mark Accessors

- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle
{
    if (indicatorStyle == UIScrollViewIndicatorStyleWhite) {
        self.layer.fillColor = [UIColor colorWithWhite:1 alpha:128.0/255.0].CGColor;
        self.layer.strokeColor = nil;
        self.layer.lineWidth = 0;
    }
    else {
        self.layer.fillColor = [UIColor colorWithWhite:0 alpha:128.0/255.0].CGColor;
        self.layer.strokeColor = [UIColor colorWithWhite:1 alpha:38.0/255.0].CGColor;
        self.layer.lineWidth = 2;
    }
}

- (UIBezierPath*)bezierPath
{
    return [UIBezierPath bezierPathWithCGPath:self.layer.path];
}

- (void)setBezierPath:(UIBezierPath*)bezierPath
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.layer.path = bezierPath.CGPath;
    
    [CATransaction commit];
}

#pragma mark -

#pragma mark Animations

- (void)animateFromBezierPath:(UIBezierPath*)fromBezierPath
                 toBezierPath:(UIBezierPath*)toBezierPath
                     duration:(NSTimeInterval)duration
{
    // NOTE: CAShapeLayer's 'path' won't implicit-animate
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = (__bridge id)fromBezierPath.CGPath;
    animation.toValue = (__bridge id)toBezierPath.CGPath;
    [self.layer addAnimation:animation forKey:nil];
    
    self.layer.path = toBezierPath.CGPath;
}

@end
