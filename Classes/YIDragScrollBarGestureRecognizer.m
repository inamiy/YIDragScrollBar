//
//  YIDragScrollBarGestureRecognizer.m
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "YIDragScrollBarGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIScrollView+YIDragScrollBar.h"


@implementation YIDragScrollBarGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _verticalScrollIndicatorTouchInsets = UIEdgeInsetsMake(0, 20, 0, 20);   // expand left & right
        _horizontalScrollIndicatorTouchInsets = UIEdgeInsetsMake(20, 0, 20, 0); // expand top & bottom
        
        _shouldFailWhenIndicatorsAreHidden = YES;
        
        self.minimumPressDuration = 0;
    }
    return self;
}

- (UIScrollView*)scrollView
{
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView*)self.view;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // fail if view is not UIScrollView
    if (![self.view isKindOfClass:[UIScrollView class]]) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    // fail if both indicators are disabled
    if (!self.scrollView.showsVerticalScrollIndicator && !self.scrollView.showsHorizontalScrollIndicator) {
        
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    BOOL isVerticalVisible = (((CALayer*)self.scrollView.verticalScrollIndicatorView.layer.presentationLayer).opacity > 0.01);
    BOOL isHorizontalVisible = (((CALayer*)self.scrollView.horizontalScrollIndicatorView.layer.presentationLayer).opacity > 0.01);
    BOOL isDraggingVerticalVisible = !!self.scrollView.draggingVerticalScrollIndicatorView.superview;
    BOOL isDraggingHorizontalVisible = !!self.scrollView.draggingHorizontalScrollIndicatorView.superview;
    
    // fail if all indicators are not visible
    if (!self.shouldFailWhenIndicatorsAreHidden ||
        (!isVerticalVisible && !isHorizontalVisible && !isDraggingVerticalVisible && !isDraggingHorizontalVisible)) {
        
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
    
    if ([touches count] == [[event allTouches] count]) {
        
        UIScrollView* scrollView = self.scrollView;
        
        // NOTE: using [gesture locationInView:scrollView] will cause unexpected result when scrolled
        CGPoint location = [self locationInView:scrollView.superview];
        
        _firstTouchArea = YIDragScrollBarGestureRecognizerFirstTouchAreaNone;
        
        // update original-indicator's frame before handling
        [self.scrollView resetScrollIndicators];
        
        // vertical
        if (self.scrollView.showsVerticalScrollIndicator) {
            
            UIEdgeInsets padding = _verticalScrollIndicatorTouchInsets;
            
            UIView* indicatorView = scrollView.verticalScrollIndicatorView;
            
            // NOTE: indicator's length must be shorter than scrollView's length
            if (indicatorView && self.scrollView.canScrollVertically) {
                CGRect touchRect = UIEdgeInsetsInsetRect(indicatorView.frame,
                                                         UIEdgeInsetsMake(-padding.top, -padding.left, -padding.bottom, -padding.right));
                touchRect = [self.scrollView.superview convertRect:touchRect fromView:self.scrollView];
                
                if (CGRectContainsPoint(touchRect, location)) {
                    
                    [self _stopBouncingIfNeeded];
                    
                    _firstTouchLocation = location;
                    _firstTouchArea = YIDragScrollBarGestureRecognizerFirstTouchAreaVertical;
                    return;
                }
            }
        }
        
        // horizontal
        if (self.scrollView.showsVerticalScrollIndicator) {
            
            UIEdgeInsets padding = _horizontalScrollIndicatorTouchInsets;
            
            UIView* indicatorView = scrollView.horizontalScrollIndicatorView;
            
            // NOTE: indicator's length must be shorter than scrollView's length
            if (indicatorView && self.scrollView.canScrollHorizontally) {
                CGRect touchRect = UIEdgeInsetsInsetRect(indicatorView.frame,
                                                         UIEdgeInsetsMake(-padding.top, -padding.left, -padding.bottom, -padding.right));
                touchRect = [self.scrollView.superview convertRect:touchRect fromView:self.scrollView];
                
                if (CGRectContainsPoint(touchRect, location)) {
                    
                    [self _stopBouncingIfNeeded];
                    
                    _firstTouchLocation = location;
                    _firstTouchArea = YIDragScrollBarGestureRecognizerFirstTouchAreaHorizontal;
                    return;
                }
            }
        }
        
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)_stopBouncingIfNeeded
{
    //
    // NOTE:
    // It is very dangerous to use original-indicator's frame when bouncing,
    // so force scrollView to stop bouncing by setting noBounceOffset
    // which doesn't exceed scrollView.contentSize+insets.
    //
    // This must be done before performing gesture's phase=began action.
    //
    
    CGPoint noBounceOffset;
    
    // take care of small self.scrollView.contentSize which doesn't bounce
    CGSize contentSize = CGSizeMake(MAX(self.scrollView.contentSize.width, self.scrollView.bounds.size.width),
                                    MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height));
    
    noBounceOffset.x = MIN(MAX(self.scrollView.contentOffset.x, -self.scrollView.contentInset.left),
                           contentSize.width+self.scrollView.contentInset.right-self.scrollView.bounds.size.width);
    noBounceOffset.y = MIN(MAX(self.scrollView.contentOffset.y, -self.scrollView.contentInset.top),
                           contentSize.height+self.scrollView.contentInset.bottom-self.scrollView.bounds.size.height);
    
    if (!CGPointEqualToPoint(self.scrollView.contentOffset, noBounceOffset)) {
        self.scrollView.contentOffset = noBounceOffset;
        
        [self.scrollView resetScrollIndicators];
        // [self.scrollView setNeedsLayout]; // this doesn't work
    }
}

- (void)reset
{
    [super reset];
    
    _firstTouchLocation = CGPointZero;
    _firstTouchArea = YIDragScrollBarGestureRecognizerFirstTouchAreaNone;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    // stop other gestures e.g. UIScrollViewPanGestureRecognizer
    if (!CGPointEqualToPoint(_firstTouchLocation, CGPointZero)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    if (!CGPointEqualToPoint(_firstTouchLocation, CGPointZero) && ![preventingGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        
        //
        // Force-cancel other gestures (e.g. scrolling) for iOS6,
        // except UIScreenEdgePanGestureRecognizer which should have higher priority.
        //
        // NOTE:
        // iOS5 calls canPreventGestureRecognizer when other gesture is active but not for iOS6,
        // so we implement cancelling logic on canBePreventedByGestureRecognizer here.
        //
        BOOL enabled = preventingGestureRecognizer.enabled;
        preventingGestureRecognizer.enabled = NO;
        preventingGestureRecognizer.enabled = enabled;
        
        return NO;
    }
    else {
        return YES;
    }
}

@end
