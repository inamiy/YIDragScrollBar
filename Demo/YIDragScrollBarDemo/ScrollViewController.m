//
//  ScrollViewController.m
//  YIDragScrollBarDemo
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "ScrollViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ScrollViewController () <UIScrollViewDelegate, YIDragScrollBarDelegate>

@end

@implementation ScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    const CGFloat aPadding = 40;
    
    UIEdgeInsets padding = UIEdgeInsetsMake(aPadding, aPadding, aPadding, aPadding);
    
    CGRect backgroundFrame = self.backgroundView.frame;
    backgroundFrame.size = self.defaultContentSize;
    self.backgroundView.frame = backgroundFrame;
    
    self.backgroundView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
    self.backgroundView.layer.borderWidth = aPadding*0.5;
    
    CGSize contentViewSize = CGSizeMake(self.defaultContentSize.width-padding.left-padding.right,
                                        self.defaultContentSize.height-padding.top-padding.bottom);
    
    self.label.frame = CGRectMake(padding.left, padding.top, contentViewSize.width, contentViewSize.height);
    
    self.scrollView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:239.0/255.0 blue:208.0/255.0 alpha:1];
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.defaultContentSize;
    self.scrollView.contentInset = self.defaultContentInsets;
    self.scrollView.scrollIndicatorInsets = self.defaultScrollIndicatorInsets;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 4;
    
    self.scrollView.indicatorStyle = self.defaultIndicatorStyle;
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.defaultDraggingVerticalScrollIndicatorImageInsets, UIEdgeInsetsZero)) {
        self.scrollView.draggingVerticalScrollIndicatorImageInsets = self.defaultDraggingVerticalScrollIndicatorImageInsets;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(self.defaultDraggingHorizontalScrollIndicatorImageInsets, UIEdgeInsetsZero)) {
        self.scrollView.draggingHorizontalScrollIndicatorImageInsets = self.defaultDraggingHorizontalScrollIndicatorImageInsets;
    }
    
    self.scrollView.dragScrollBarDelegate = self;
}

// for iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backgroundView;
}

#pragma mark -

#pragma mark YIDragScrollBarDelegate

- (void)dragScrollBarWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
}

- (void)dragScrollBarWillEndDragging:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
}

@end
