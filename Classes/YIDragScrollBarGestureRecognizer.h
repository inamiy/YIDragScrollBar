//
//  YIDragScrollBarGestureRecognizer.h
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YIDragScrollBarGestureRecognizerFirstTouchArea) {
    YIDragScrollBarGestureRecognizerFirstTouchAreaNone,
    YIDragScrollBarGestureRecognizerFirstTouchAreaVertical,
    YIDragScrollBarGestureRecognizerFirstTouchAreaHorizontal,
};


@interface YIDragScrollBarGestureRecognizer : UILongPressGestureRecognizer

// insets to expand touch area relative to original-indicator's frame
@property (nonatomic) UIEdgeInsets verticalScrollIndicatorTouchInsets;      // default = {.left = 20, .right = 20}
@property (nonatomic) UIEdgeInsets horizontalScrollIndicatorTouchInsets;    // default = {.top = 20, .bottom = 20}

@property (nonatomic) BOOL shouldFailWhenIndicatorsAreHidden;   // default = YES

@property (nonatomic, readonly) CGPoint firstTouchLocation;
@property (nonatomic, readonly) YIDragScrollBarGestureRecognizerFirstTouchArea firstTouchArea;

@end
