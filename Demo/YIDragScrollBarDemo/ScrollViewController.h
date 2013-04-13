//
//  ScrollViewController.h
//  YIDragScrollBarDemo
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic) CGSize defaultContentSize;    // contentView.size + 20pt padding
@property (nonatomic) UIEdgeInsets defaultContentInsets;
@property (nonatomic) UIEdgeInsets defaultScrollIndicatorInsets;
@property (nonatomic) UIScrollViewIndicatorStyle defaultIndicatorStyle;

@property (nonatomic) UIEdgeInsets defaultDraggingVerticalScrollIndicatorImageInsets;      // only uses left & right, default = {.left = 10}
@property (nonatomic) UIEdgeInsets defaultDraggingHorizontalScrollIndicatorImageInsets;    // only uses top & bottom, default = {.top = 10}


@end
