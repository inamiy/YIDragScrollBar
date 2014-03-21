//
//  UIScrollView+YIDragScrollBar.h
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YIDragScrollBarDelegate.h"

@interface UIScrollView (YIDragScrollBar) <UIGestureRecognizerDelegate>

#pragma mark Common

@property (nonatomic) BOOL canDragScrollBar;

@property (nonatomic, readonly) BOOL canScrollVertically;
@property (nonatomic, readonly) BOOL canScrollHorizontally;

@property (nonatomic, readonly) UIImageView* verticalScrollIndicatorView;
@property (nonatomic, readonly) UIImageView* horizontalScrollIndicatorView;

- (void)resetScrollIndicators;

#pragma mark DragScrollBar

@property (nonatomic, weak) id <YIDragScrollBarDelegate> dragScrollBarDelegate;

@property (nonatomic, readonly) BOOL isDraggingScrollBar;

@property (nonatomic, strong, readonly) UIView* draggingVerticalScrollIndicatorView;
@property (nonatomic, strong, readonly) UIView* draggingHorizontalScrollIndicatorView;

@property (nonatomic, readonly) BOOL showsScrollIndicatorBackground;    // default = YES

// insets to stretch original-indicator
@property (nonatomic) UIEdgeInsets draggingVerticalScrollIndicatorImageInsets;   // only uses left & right, default = {.left = 10}
@property (nonatomic) UIEdgeInsets draggingHorizontalScrollIndicatorImageInsets; // only uses top & bottom, default = {.top = 10}

#pragma mark Default Settings

// set NO to disable dragScrollBar on each scrollView-init. defalut = YES.
+ (void)setDefaultDragScrollBarEnabled:(BOOL)defaultDragScrollBarEnabled;

@end
