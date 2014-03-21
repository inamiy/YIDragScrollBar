//
//  UIScrollView+YIDragScrollBar.m
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "UIScrollView+YIDragScrollBar.h"
#import "YIDragScrollBarGestureRecognizer.h"
#import "YIDragScrollIndicatorView.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "JRSwizzle.h"

#define STRETCH_DURATION    0.3
#define HIDE_DURATION       0.2

// Interestingly, black original-indicator's image has width=7, but white has width=5.
// We only define one threshold to support any length below it. 
#define MAX_INDICATOR_THICKNESS 7

// very small correction between indicator's image & CAShapeLayer drawing
#define INDICATOR_IMAGE_CORRECTION  (self.indicatorStyle == UIScrollViewIndicatorStyleWhite ? 0.5 : 1)

#define INDICATOR_MARGIN    1

#define BACKGROUND_VIEW_COLOR    [UIColor colorWithWhite:0.25 alpha:0.5]

static const char __showsScrollIndicatorBackgroundKey;

static const char __dragScrollBarDelegateKey;

static const char __draggingVerticalScrollIndicatorViewKey;
static const char __draggingHorizontalScrollIndicatorViewKey;

static const char __draggingVerticalScrollIndicatorImageInsetsKey;
static const char __draggingHorizontalScrollIndicatorImageInsetsKey;

static const char __draggingScrollBarGestureKey;
static const char __draggingScrollBarObservingKey;

static const char __draggingVerticalScrollIndicatorBackgroundViewKey;
static const char __draggingHorizontalScrollIndicatorBackgroundViewKey;

static char __draggingScrollBarObservingContext;

static BOOL __defaultDragScrollBarEnabled = YES;


@interface UIScrollView (YIDragScrollBarPrivate)

@property (nonatomic, strong) YIDragScrollIndicatorView* draggingVerticalScrollIndicatorView;
@property (nonatomic, strong) YIDragScrollIndicatorView* draggingHorizontalScrollIndicatorView;

@property (nonatomic, strong) UIView* draggingVerticalScrollIndicatorBackgroundView;
@property (nonatomic, strong) UIView* draggingHorizontalScrollIndicatorBackgroundView;

@end


@implementation UIScrollView (YIDragScrollBar)

+ (void)setDefaultDragScrollBarEnabled:(BOOL)defaultDragScrollBarEnabled
{
    __defaultDragScrollBarEnabled = defaultDragScrollBarEnabled;
}

#pragma mark Accessors

#pragma mark original-indicator

- (BOOL)canScrollVertically
{
    return (self.contentSize.height+self.contentInset.top+self.contentInset.bottom > self.bounds.size.height);
}

- (BOOL)canScrollHorizontally
{
    return (self.contentSize.width+self.contentInset.left+self.contentInset.right > self.bounds.size.width);
}

- (BOOL)showsScrollIndicatorBackground
{
    BOOL shows = [objc_getAssociatedObject(self, &__showsScrollIndicatorBackgroundKey) boolValue];
    return shows;
}

- (void)setShowsScrollIndicatorBackground:(BOOL)shows
{
    objc_setAssociatedObject(self, &__showsScrollIndicatorBackgroundKey, @(shows), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView*)verticalScrollIndicatorView
{
    // COMMENT-OUT: BAD_ACCESS if tableViewCell is reordered
//    UIImageView* indicatorView = objc_getAssociatedObject(self, &__verticalScrollIndicatorViewKey);
    
    UIImageView* indicatorView = nil;   // always search
    
    if (!indicatorView) {
        for (UIImageView* subview in [self.subviews reverseObjectEnumerator]) {
            
            if ([subview isKindOfClass:[UIImageView class]] &&
                subview.frame.size.width <= MAX_INDICATOR_THICKNESS &&
                subview.frame.size.width < subview.frame.size.height) {
                
                indicatorView = subview;
                
//                objc_setAssociatedObject(self, &__verticalScrollIndicatorViewKey, indicatorView, OBJC_ASSOCIATION_ASSIGN);
                break;
            }
        }
    }
    
    return indicatorView;
}

- (UIImageView*)horizontalScrollIndicatorView
{
    // COMMENT-OUT: BAD_ACCESS if tableViewCell is reordered
//    UIImageView* indicatorView = objc_getAssociatedObject(self, &__horizontalScrollIndicatorViewKey);
    
    UIImageView* indicatorView = nil;   // always search
    
    if (!indicatorView) {
        for (UIImageView* subview in [self.subviews reverseObjectEnumerator]) {
            
            if ([subview isKindOfClass:[UIImageView class]] &&
                subview.frame.size.height <= MAX_INDICATOR_THICKNESS &&
                subview.frame.size.width > subview.frame.size.height) {
                
                indicatorView = subview;
                
//                objc_setAssociatedObject(self, &__horizontalScrollIndicatorViewKey, indicatorView, OBJC_ASSOCIATION_ASSIGN);
                break;
            }
        }
    }
    
    return indicatorView;
}

#pragma mark dragging-indicator

- (BOOL)isDraggingScrollBar
{
    return self.draggingScrollBarGestureRecognizer.state != UIGestureRecognizerStatePossible;
}

- (BOOL)canDragScrollBar
{
    return self.draggingScrollBarGestureRecognizer.enabled;
}

- (void)setCanDragScrollBar:(BOOL)canDragScrollBar
{
    self.draggingScrollBarGestureRecognizer.enabled = canDragScrollBar;
}

- (id <YIDragScrollBarDelegate>)dragScrollBarDelegate
{
    id <YIDragScrollBarDelegate> dragScrollBarDelegate = objc_getAssociatedObject(self, &__dragScrollBarDelegateKey);
    return dragScrollBarDelegate;
}

- (void)setDragScrollBarDelegate:(id <YIDragScrollBarDelegate>)dragScrollBarDelegate
{
    objc_setAssociatedObject(self, &__dragScrollBarDelegateKey, dragScrollBarDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (YIDragScrollIndicatorView*)draggingVerticalScrollIndicatorView
{
    YIDragScrollIndicatorView* indicatorView = objc_getAssociatedObject(self, &__draggingVerticalScrollIndicatorViewKey);
    return indicatorView;
}

- (void)setDraggingVerticalScrollIndicatorView:(YIDragScrollIndicatorView*)draggingScrollIndicatorView
{
    objc_setAssociatedObject(self, &__draggingVerticalScrollIndicatorViewKey, draggingScrollIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YIDragScrollIndicatorView*)draggingHorizontalScrollIndicatorView
{
    YIDragScrollIndicatorView* indicatorView = objc_getAssociatedObject(self, &__draggingHorizontalScrollIndicatorViewKey);
    return indicatorView;
}

- (void)setDraggingHorizontalScrollIndicatorView:(YIDragScrollIndicatorView*)draggingScrollIndicatorView
{
    objc_setAssociatedObject(self, &__draggingHorizontalScrollIndicatorViewKey, draggingScrollIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark stretching width/height

- (UIEdgeInsets)draggingVerticalScrollIndicatorImageInsets
{
    UIEdgeInsets imageInsets = [objc_getAssociatedObject(self, &__draggingVerticalScrollIndicatorImageInsetsKey) UIEdgeInsetsValue];
    imageInsets.top = 0;    // invalidate
    imageInsets.bottom = 0; // invalidate
    return imageInsets;
}

- (void)setDraggingVerticalScrollIndicatorImageInsets:(UIEdgeInsets)imageInsets
{
    objc_setAssociatedObject(self, &__draggingVerticalScrollIndicatorImageInsetsKey, [NSValue valueWithUIEdgeInsets:imageInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)draggingHorizontalScrollIndicatorImageInsets
{
    UIEdgeInsets imageInsets = [objc_getAssociatedObject(self, &__draggingHorizontalScrollIndicatorImageInsetsKey) UIEdgeInsetsValue];
    imageInsets.left = 0;   // invalidate
    imageInsets.right = 0;  // invalidate
    return imageInsets;
}

- (void)setDraggingHorizontalScrollIndicatorImageInsets:(UIEdgeInsets)imageInsets
{
    objc_setAssociatedObject(self, &__draggingHorizontalScrollIndicatorImageInsetsKey, [NSValue valueWithUIEdgeInsets:imageInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

#pragma mark Accessors (Private)

- (YIDragScrollBarGestureRecognizer*)draggingScrollBarGestureRecognizer
{
    YIDragScrollBarGestureRecognizer* gesture = objc_getAssociatedObject(self, &__draggingScrollBarGestureKey);
    return gesture;
}

- (void)setDraggingScrollBarGestureRecognizer:(YIDragScrollBarGestureRecognizer*)draggingScrollBarGestureRecognizer
{
    objc_setAssociatedObject(self, &__draggingScrollBarGestureKey, draggingScrollBarGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isObservingForDraggingScrollBar
{
    return [objc_getAssociatedObject(self, &__draggingScrollBarObservingKey) boolValue];
}

- (void)setIsObservingForDraggingScrollBar:(BOOL)isObserving
{
    objc_setAssociatedObject(self, &__draggingScrollBarObservingKey, @(isObserving), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)verticalScrollIndicatorViewWidth
{
    return self.canScrollVertically ? self.verticalScrollIndicatorView.frame.size.width : 0;
}

- (CGFloat)horizontalScrollIndicatorViewHeight
{
    return self.canScrollHorizontally ? self.horizontalScrollIndicatorView.frame.size.height : 0;
}

- (UIView*)draggingVerticalScrollIndicatorBackgroundView
{
    UIView* indicatorView = objc_getAssociatedObject(self, &__draggingVerticalScrollIndicatorBackgroundViewKey);
    return indicatorView;
}

- (void)setDraggingVerticalScrollIndicatorBackgroundView:(UIView*)backgroundView
{
    objc_setAssociatedObject(self, &__draggingVerticalScrollIndicatorBackgroundViewKey, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)draggingHorizontalScrollIndicatorBackgroundView
{
    UIView* indicatorView = objc_getAssociatedObject(self, &__draggingHorizontalScrollIndicatorBackgroundViewKey);
    return indicatorView;
}

- (void)setDraggingHorizontalScrollIndicatorBackgroundView:(UIView*)backgroundView
{
    objc_setAssociatedObject(self, &__draggingHorizontalScrollIndicatorBackgroundViewKey, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

#pragma mark Gestures

- (void)handleDraggingScrollBarGesture:(YIDragScrollBarGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if ([self.dragScrollBarDelegate respondsToSelector:@selector(dragScrollBarWillBeginDragging:)]) {
            [self.dragScrollBarDelegate dragScrollBarWillBeginDragging:self];
        }
        
        [self setupDraggingScrollIndicatorViewsAnimated:YES];
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        [self updateContentOffsetViaDragScrollBar];
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled ||
             gesture.state == UIGestureRecognizerStateFailed) {
        
        if ([self.dragScrollBarDelegate respondsToSelector:@selector(dragScrollBarWillEndDragging:)]) {
            [self.dragScrollBarDelegate dragScrollBarWillEndDragging:self];
        }
        
        [self teardownDraggingScrollIndicatorViewsAnimated:YES];
        
    }
}

- (void)setupDraggingScrollIndicatorViewsAnimated:(BOOL)animated
{
    YIDragScrollBarGestureRecognizer* gesture = self.draggingScrollBarGestureRecognizer;
    
    [self.draggingVerticalScrollIndicatorBackgroundView removeFromSuperview];
    [self.draggingHorizontalScrollIndicatorBackgroundView removeFromSuperview];
    
    [self.draggingVerticalScrollIndicatorView removeFromSuperview];
    [self.draggingHorizontalScrollIndicatorView removeFromSuperview];
    
    // temporarily hide original-indicators
    self.verticalScrollIndicatorView.hidden = YES;
    self.horizontalScrollIndicatorView.hidden = YES;
    
    // vertical
    if (gesture.firstTouchArea == YIDragScrollBarGestureRecognizerFirstTouchAreaVertical) {
        
        //
        // NOTE:
        // There are cases when original-indicator may be removed & reallocated (e.g. tableView reorder).
        // If so, force-cancel current gesture.
        //
        if (!self.verticalScrollIndicatorView) {
            
            // force-cancel
            BOOL enabled = gesture.enabled;
            gesture.enabled = NO;
            gesture.enabled = enabled;
            
            return;
        }
        
        //--------------------------------------------------
        // create dragging-indicator
        //--------------------------------------------------
        CGRect imageRect = self.verticalScrollIndicatorView.frame;
        
        UIEdgeInsets imageInsets = self.draggingVerticalScrollIndicatorImageInsets;
        
        CGRect stretchedRect = UIEdgeInsetsInsetRect(imageRect, UIEdgeInsetsMake(-imageInsets.top, -imageInsets.left, -imageInsets.bottom, -imageInsets.right));
        
        CGSize imageSize = imageRect.size;
        CGSize stretchedSize = stretchedRect.size;
        
        YIDragScrollIndicatorView* draggingView = [[YIDragScrollIndicatorView alloc] initWithFrame:stretchedRect indicatorStyle:self.indicatorStyle];
        [self insertSubview:draggingView belowSubview:self.verticalScrollIndicatorView];
        
        self.draggingVerticalScrollIndicatorView = draggingView;
        
        //--------------------------------------------------
        // create background
        //--------------------------------------------------
        UIView* draggingBackgroundView = nil;
        
        if (self.showsScrollIndicatorBackground) {
            CGRect backgroundRect = stretchedRect;
            backgroundRect.origin.y = self.contentOffset.y+self.scrollIndicatorInsets.top;
            backgroundRect.size.height = self.frame.size.height-self.scrollIndicatorInsets.top-self.scrollIndicatorInsets.bottom-self.horizontalScrollIndicatorViewHeight;
            
            draggingBackgroundView = [[UIView alloc] initWithFrame:backgroundRect];
            draggingBackgroundView.userInteractionEnabled = NO;
            draggingBackgroundView.alpha = 0;
            draggingBackgroundView.backgroundColor = BACKGROUND_VIEW_COLOR;
            draggingBackgroundView.layer.cornerRadius = backgroundRect.size.width/2;
            [self insertSubview:draggingBackgroundView belowSubview:draggingView];
            
            self.draggingVerticalScrollIndicatorBackgroundView = draggingBackgroundView;
        }
        
        //--------------------------------------------------
        // animate
        //--------------------------------------------------
        CGFloat c = INDICATOR_IMAGE_CORRECTION;
        
        UIBezierPath* fromPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(imageInsets.left+c,
                                                           imageInsets.top+c,
                                                           imageSize.width-2*c,
                                                           imageSize.height-2*c)
                                   cornerRadius:(imageSize.width-2*c)/2];
        
        UIBezierPath* toPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(c,
                                                           c,
                                                           stretchedSize.width-2*c,
                                                           stretchedSize.height-2*c)
                                   cornerRadius:(stretchedSize.width-2*c)/2];
        
        if (animated) {
            
            [draggingView animateFromBezierPath:fromPath
                                   toBezierPath:toPath
                                       duration:STRETCH_DURATION];
            
            [UIView animateWithDuration:STRETCH_DURATION animations:^{
                draggingBackgroundView.alpha = 1;
            }];
            
        }
        else {
            draggingView.bezierPath = toPath;
            draggingBackgroundView.alpha = 1;
        }
        
    }
    // horizontal
    else if (gesture.firstTouchArea == YIDragScrollBarGestureRecognizerFirstTouchAreaHorizontal) {
        
        // force-cancel current gesture if needed
        if (!self.horizontalScrollIndicatorView) {
            
            // force-cancel
            BOOL enabled = gesture.enabled;
            gesture.enabled = NO;
            gesture.enabled = enabled;
            
            return;
        }
        
        //--------------------------------------------------
        // create dragging-indicator
        //--------------------------------------------------
        CGRect imageRect = self.horizontalScrollIndicatorView.frame;
        
        UIEdgeInsets imageInsets = self.draggingHorizontalScrollIndicatorImageInsets;
        
        CGRect stretchedRect = UIEdgeInsetsInsetRect(imageRect, UIEdgeInsetsMake(-imageInsets.top, -imageInsets.left, -imageInsets.bottom, -imageInsets.right));
        
        CGSize imageSize = imageRect.size;
        CGSize stretchedSize = stretchedRect.size;
        
        YIDragScrollIndicatorView* draggingView = [[YIDragScrollIndicatorView alloc] initWithFrame:stretchedRect indicatorStyle:self.indicatorStyle];
        [self insertSubview:draggingView belowSubview:self.horizontalScrollIndicatorView];
        
        self.draggingHorizontalScrollIndicatorView = draggingView;
        
        //--------------------------------------------------
        // create background
        //--------------------------------------------------
        UIView* draggingBackgroundView = nil;
        
        if (self.showsScrollIndicatorBackground) {
            CGRect backgroundRect = stretchedRect;
            backgroundRect.origin.x = self.contentOffset.x+self.scrollIndicatorInsets.left;
            backgroundRect.size.width = self.frame.size.width-self.scrollIndicatorInsets.left-self.scrollIndicatorInsets.right-self.verticalScrollIndicatorViewWidth;
            
            draggingBackgroundView = [[UIView alloc] initWithFrame:backgroundRect];
            draggingBackgroundView.userInteractionEnabled = NO;
            draggingBackgroundView.alpha = 0;
            draggingBackgroundView.backgroundColor = BACKGROUND_VIEW_COLOR;
            draggingBackgroundView.layer.cornerRadius = backgroundRect.size.height/2;
            [self insertSubview:draggingBackgroundView belowSubview:draggingView];
            
            self.draggingHorizontalScrollIndicatorBackgroundView = draggingBackgroundView;
        }
        
        //--------------------------------------------------
        // animate
        //--------------------------------------------------
        CGFloat c = INDICATOR_IMAGE_CORRECTION;
        
        UIBezierPath* fromPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(imageInsets.left+c,
                                                           imageInsets.top+c,
                                                           imageSize.width-2*c,
                                                           imageSize.height-2*c)
                                   cornerRadius:(imageSize.height-2*c)/2];
        
        UIBezierPath* toPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(c,
                                                           c,
                                                           stretchedSize.width-2*c,
                                                           stretchedSize.height-2*c)
                                   cornerRadius:(stretchedSize.height-2*c)/2];
        
        if (animated) {
            
            [draggingView animateFromBezierPath:fromPath
                                   toBezierPath:toPath
                                       duration:STRETCH_DURATION];
            
            [UIView animateWithDuration:STRETCH_DURATION animations:^{
                draggingBackgroundView.alpha = 1;
            }];
            
        }
        else {
            draggingView.bezierPath = toPath;
            draggingBackgroundView.alpha = 1;
        }
        
    }
    
    // make sure to bring original-indicators to front
    [self bringSubviewToFront:self.verticalScrollIndicatorView];
    [self bringSubviewToFront:self.horizontalScrollIndicatorView];
}

- (void)updateContentOffsetViaDragScrollBar
{
    YIDragScrollBarGestureRecognizer* gesture = self.draggingScrollBarGestureRecognizer;
    
    CGPoint touchPoint = [gesture locationInView:self.superview];
    touchPoint = CGPointMake(touchPoint.x-self.frame.origin.x, touchPoint.y-self.frame.origin.y);
    
    CGSize selfSize = self.bounds.size;
    CGSize contentSize = self.contentSize;
    CGPoint contentOffset = self.contentOffset;
    UIEdgeInsets cInsets = self.contentInset;
    UIEdgeInsets sInsets = self.scrollIndicatorInsets;
    
    CGFloat verticalHeight = self.draggingVerticalScrollIndicatorView.frame.size.height;
    CGFloat horizontalWidth = self.draggingHorizontalScrollIndicatorView.frame.size.width;
    
    CGPoint targetOffset = contentOffset;
    
    // vertical
    if (self.draggingVerticalScrollIndicatorView.superview) {
        
        // percentage = (touchPoint-indicator/2)/(selfSize-indicator)
        CGFloat percentageY = (touchPoint.y-sInsets.top-verticalHeight/2)/(selfSize.height-sInsets.top-sInsets.bottom-verticalHeight);
        percentageY = MIN(MAX(0, percentageY), 1);
        
        targetOffset.y = percentageY*(contentSize.height+cInsets.top+cInsets.bottom-selfSize.height);
        targetOffset.y = MIN(MAX(0, targetOffset.y), contentSize.height+cInsets.top+cInsets.bottom)-cInsets.top;
    }
    
    // horizontal
    if (self.draggingHorizontalScrollIndicatorView.superview) {
        
        // percentage = (touchPoint-indicator/2)/(selfSize-indicator)
        CGFloat percentageX = (touchPoint.x-sInsets.left-horizontalWidth/2)/(selfSize.width-sInsets.left-sInsets.right-horizontalWidth);
        percentageX = MIN(MAX(0, percentageX), 1);
        
        targetOffset.x = percentageX*(contentSize.width+cInsets.left+cInsets.right-selfSize.width);
        targetOffset.x = MIN(MAX(0, targetOffset.x), contentSize.width+cInsets.left+cInsets.right)-cInsets.left;
    }
    
    [self setContentOffset:targetOffset animated:NO];
    
    // required to overcome iOS5 section-header
    [self bringSubviewToFront:self.draggingVerticalScrollIndicatorBackgroundView];
    [self bringSubviewToFront:self.draggingHorizontalScrollIndicatorBackgroundView];
    [self bringSubviewToFront:self.draggingVerticalScrollIndicatorView];
    [self bringSubviewToFront:self.draggingHorizontalScrollIndicatorView];
}

- (void)teardownDraggingScrollIndicatorViewsAnimated:(BOOL)animated
{
    YIDragScrollIndicatorView* draggingIndicatorView = nil;
    UIView* draggingBackgroundView = nil;
    UIBezierPath* fromPath = nil;
    UIBezierPath* toPath = nil;
    
    // vertical
    if (self.draggingVerticalScrollIndicatorView.superview) {
        
        draggingIndicatorView = self.draggingVerticalScrollIndicatorView;
        draggingBackgroundView = self.draggingVerticalScrollIndicatorBackgroundView;
        
        UIEdgeInsets imageInsets = self.draggingVerticalScrollIndicatorImageInsets;
        
        CGSize imageSize = self.verticalScrollIndicatorView.frame.size;
        CGSize stretchedSize = draggingIndicatorView.frame.size;
        
        CGFloat c = INDICATOR_IMAGE_CORRECTION;
        
        toPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(imageInsets.left+c,
                                                                    imageInsets.top+c,
                                                                    imageSize.width-2*c,
                                                                    imageSize.height-2*c)
                                            cornerRadius:(imageSize.width-2*c)/2];
        
        fromPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(c,
                                                                      c,
                                                                      stretchedSize.width-2*c,
                                                                      stretchedSize.height-2*c)
                                              cornerRadius:(stretchedSize.width-2*c)/2];
        
        // safely update original-indicator's position
        CGRect frame = self.verticalScrollIndicatorView.frame;
        frame.origin.y = draggingIndicatorView.frame.origin.y;
        self.verticalScrollIndicatorView.frame = frame;
        
    }
    // horizontal
    else if (self.draggingHorizontalScrollIndicatorView.superview) {
        draggingIndicatorView = self.draggingHorizontalScrollIndicatorView;
        draggingBackgroundView = self.draggingHorizontalScrollIndicatorBackgroundView;
        
        UIEdgeInsets imageInsets = self.draggingHorizontalScrollIndicatorImageInsets;
        
        CGSize imageSize = self.horizontalScrollIndicatorView.frame.size;
        CGSize stretchedSize = draggingIndicatorView.frame.size;
        
        CGFloat c = INDICATOR_IMAGE_CORRECTION;
        
        toPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(imageInsets.left+c,
                                                                    imageInsets.top+c,
                                                                    imageSize.width-2*c,
                                                                    imageSize.height-2*c)
                                            cornerRadius:(imageSize.height-2*c)/2];
        
        fromPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(c,
                                                                      c,
                                                                      stretchedSize.width-2*c,
                                                                      stretchedSize.height-2*c)
                                              cornerRadius:(stretchedSize.height-2*c)/2];
        
        // safely update original-indicator's position
        CGRect frame = self.horizontalScrollIndicatorView.frame;
        frame.origin.x = draggingIndicatorView.frame.origin.x;
        self.horizontalScrollIndicatorView.frame = frame;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [CATransaction begin];
    [CATransaction setDisableActions:!animated];
    [CATransaction setCompletionBlock:^{
        
        // update original-indicator's position
        // (required especially when scrolling both vertically & horizontally, or un-positioned original-indicator may suffer touch events & dragging-scroll-UI)
        [weakSelf resetScrollIndicators];
        // [weakSelf setNeedsLayout];   // this doesn't work
        
        // show original-indicators again
        weakSelf.verticalScrollIndicatorView.hidden = NO;
        weakSelf.horizontalScrollIndicatorView.hidden = NO;
        
        // remove dragging-indicator
        [draggingIndicatorView removeFromSuperview];
        [draggingBackgroundView removeFromSuperview];
        
    }];
    
    if (animated) {
        CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.beginTime = STRETCH_DURATION;
        opacityAnimation.duration = HIDE_DURATION;
        opacityAnimation.toValue = @(0);
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = NO;
        
        CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = STRETCH_DURATION;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = (__bridge id)fromPath.CGPath;
        pathAnimation.toValue = (__bridge id)toPath.CGPath;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = @[pathAnimation, opacityAnimation];
        group.duration = STRETCH_DURATION+HIDE_DURATION;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        [draggingIndicatorView.layer addAnimation:group forKey:nil];
        
        [UIView animateWithDuration:STRETCH_DURATION animations:^{
            draggingBackgroundView.alpha = 0;
        }];
    }
    
    [CATransaction commit];
}

#pragma mark -

#pragma mark Layout

//
// reset original-indicators without flashing
// (NOTE: this seems to work fine, but it is better not to call too often since it uses '-flashScrollIndicators')
//
- (void)resetScrollIndicators
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self flashScrollIndicators];
    
    [CATransaction commit];
    
    self.verticalScrollIndicatorView.alpha = 0;
    self.horizontalScrollIndicatorView.alpha = 0;
}

//
// layout dragging-indicators manually
// (NOTE: you can't use original-indicator's frame here, since it doesn't update when hidden)
//
- (void)layoutDraggingScrollIndicatorViews
{
    // find original-indicators first in order to bring to front 
    UIImageView* verticalScrollIndicatorView = self.verticalScrollIndicatorView;
    UIImageView* horizontalScrollIndicatorView = self.horizontalScrollIndicatorView;
    
    // vertical
    if (self.draggingVerticalScrollIndicatorView.superview) {
        
        CGSize selfSize = self.bounds.size;
        CGSize contentSize = self.contentSize;
        CGPoint contentOffset = self.contentOffset;
        UIEdgeInsets cInsets = self.contentInset;
        UIEdgeInsets sInsets = self.scrollIndicatorInsets;
        
        // use current dragging-indicator's size to calculate preferred offset
        CGFloat verticalHeight = self.draggingVerticalScrollIndicatorView.frame.size.height;
        
        // consider tail-truncation if both veritcal & horizontal indicators are visible
        CGFloat horizontalHeight = self.horizontalScrollIndicatorViewHeight;
        
        // percentage = contentOffset/(contentSize-selfSize)
        CGFloat percentageY = (contentOffset.y+cInsets.top)/(contentSize.height+cInsets.top+cInsets.bottom-selfSize.height);
        
        CGFloat draggingIndicatorOffsetY = INDICATOR_MARGIN+sInsets.top+percentageY*(contentSize.height+cInsets.top+cInsets.bottom-sInsets.top-sInsets.bottom-verticalHeight-horizontalHeight-INDICATOR_MARGIN*2)-cInsets.top;
        
        // if NaN
        if (draggingIndicatorOffsetY != draggingIndicatorOffsetY) {
            draggingIndicatorOffsetY = 0;
        }
        
        // layout dragging-indicator
        CGRect frame = self.draggingVerticalScrollIndicatorView.frame;
        frame.origin.y = draggingIndicatorOffsetY;
        self.draggingVerticalScrollIndicatorView.frame = frame;
        
        // layout background
        frame = self.draggingVerticalScrollIndicatorBackgroundView.frame;
        frame.origin.y = contentOffset.y+sInsets.top;
        self.draggingVerticalScrollIndicatorBackgroundView.frame = frame;
        
        // required to overcome iOS5 section-header
        [self bringSubviewToFront:self.draggingVerticalScrollIndicatorBackgroundView];
        [self bringSubviewToFront:self.draggingVerticalScrollIndicatorView];
    }
    
    // horizontal
    if (self.draggingHorizontalScrollIndicatorView.superview) {
        
        CGSize selfSize = self.bounds.size;
        CGSize contentSize = self.contentSize;
        CGPoint contentOffset = self.contentOffset;
        UIEdgeInsets cInsets = self.contentInset;
        UIEdgeInsets sInsets = self.scrollIndicatorInsets;
        
        // use current dragging-indicator's size to calculate preferred offset
        CGFloat horizontalWidth = self.draggingHorizontalScrollIndicatorView.frame.size.width;
        
        // consider tail-truncation if both veritcal & horizontal indicators are visible
        CGFloat verticalWidth = self.verticalScrollIndicatorViewWidth;
        
        // percentage = contentOffset/(contentSize-selfSize)
        CGFloat percentageX = (contentOffset.x+cInsets.left)/(contentSize.width+cInsets.left+cInsets.right-selfSize.width);
        
        CGFloat draggingIndicatorOffsetX = INDICATOR_MARGIN+sInsets.left+percentageX*(contentSize.width+cInsets.left+cInsets.right-sInsets.left-sInsets.right-horizontalWidth-verticalWidth-INDICATOR_MARGIN*2)-cInsets.left;
        
        // if NaN
        if (draggingIndicatorOffsetX != draggingIndicatorOffsetX) {
            draggingIndicatorOffsetX = 0;
        }
        
        // layout dragging-indicator
        CGRect frame = self.draggingHorizontalScrollIndicatorView.frame;
        frame.origin.x = draggingIndicatorOffsetX;
        self.draggingHorizontalScrollIndicatorView.frame = frame;
        
        // layout background
        frame = self.draggingHorizontalScrollIndicatorBackgroundView.frame;
        frame.origin.x = contentOffset.x+sInsets.left;
        self.draggingHorizontalScrollIndicatorBackgroundView.frame = frame;
        
        // required to overcome iOS5 section-header
        [self bringSubviewToFront:self.draggingHorizontalScrollIndicatorBackgroundView];
        [self bringSubviewToFront:self.draggingHorizontalScrollIndicatorView];
    }
    
    // make sure to bring original-indicators to front
    [self bringSubviewToFront:verticalScrollIndicatorView];
    [self bringSubviewToFront:horizontalScrollIndicatorView];
}

@end


#pragma mark -


@implementation UIScrollView (YIDragScrollBarSwizzling)

+ (void)load
{
    [UIScrollView jr_swizzleMethod:@selector(initWithFrame:)
                        withMethod:@selector(yi_initWithFrame:)
                             error:NULL];
    
    [UIScrollView jr_swizzleMethod:@selector(initWithCoder:)
                        withMethod:@selector(yi_initWithCoder:)
                             error:NULL];
    
    [UIScrollView jr_swizzleMethod:@selector(willMoveToSuperview:)
                        withMethod:@selector(yi_willMoveToSuperview:)
                             error:NULL];
    
    [UIScrollView jr_swizzleMethod:@selector(observeValueForKeyPath:ofObject:change:context:)
                        withMethod:@selector(yi_observeValueForKeyPath:ofObject:change:context:)
                             error:NULL];
}

- (void)yi_init
{
    self.showsScrollIndicatorBackground = YES;
    
    self.draggingVerticalScrollIndicatorImageInsets = UIEdgeInsetsMake(0, 10, 0, 0);   // stretches to left
    self.draggingHorizontalScrollIndicatorImageInsets = UIEdgeInsetsMake(10, 0, 0, 0); // stretches to top
    
    YIDragScrollBarGestureRecognizer* gesture = [[YIDragScrollBarGestureRecognizer alloc] initWithTarget:self action:@selector(handleDraggingScrollBarGesture:)];
    gesture.enabled = __defaultDragScrollBarEnabled;
    [self addGestureRecognizer:gesture];
    
    self.draggingScrollBarGestureRecognizer = gesture;
}

- (id)yi_initWithFrame:(CGRect)frame
{
    id self2 = [self yi_initWithFrame:frame];
    if (self2) {
        [self2 yi_init];
    }
    return self2;
}

- (id)yi_initWithCoder:(NSCoder *)aDecoder
{
    id self2 = [self yi_initWithCoder:aDecoder];
    if (self2) {
        [self2 yi_init];
    }
    return self2;
}

- (void)yi_willMoveToSuperview:(UIView *)newSuperview
{
    [self yi_willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        if (!self.isObservingForDraggingScrollBar) {
            [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:&__draggingScrollBarObservingContext];
            [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:&__draggingScrollBarObservingContext];
            [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&__draggingScrollBarObservingContext];
            
            self.isObservingForDraggingScrollBar = YES;
        }
    }
    else {
        if (self.isObservingForDraggingScrollBar) {
            [self removeObserver:self forKeyPath:@"contentOffset"];
            [self removeObserver:self forKeyPath:@"contentSize"];
            [self removeObserver:self forKeyPath:@"frame"];
            
            self.isObservingForDraggingScrollBar = NO;
        }
    }
}

// KVO
- (void)yi_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &__draggingScrollBarObservingContext) {
        
        if ([keyPath isEqualToString:@"contentOffset"]) {
            
            [self layoutDraggingScrollIndicatorViews];
            
            // remove all animations if scrolled
            [self.draggingVerticalScrollIndicatorView.layer removeAllAnimations];
            [self.draggingHorizontalScrollIndicatorView.layer removeAllAnimations];
            
            [self.draggingVerticalScrollIndicatorBackgroundView.layer removeAllAnimations];
            [self.draggingHorizontalScrollIndicatorBackgroundView.layer removeAllAnimations];
            
        }
        //
        // reset dragging-indicators when...
        // 1. contentSize changed (frequently occurs in UIWebView)
        // 2. frame changed (mainly for rotation)
        //
        else if ([keyPath isEqualToString:@"contentSize"] || [keyPath isEqualToString:@"frame"]) {
            
            if (self.draggingScrollBarGestureRecognizer.state != UIGestureRecognizerStatePossible) {
                [self teardownDraggingScrollIndicatorViewsAnimated:NO];
                [self resetScrollIndicators];
                [self setupDraggingScrollIndicatorViewsAnimated:NO];
                [self layoutDraggingScrollIndicatorViews];
            }
            
        }
    }
    else {
        [self yi_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
