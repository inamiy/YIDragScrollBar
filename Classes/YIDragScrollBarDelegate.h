//
//  YIDragScrollBarDelegate.h
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/18.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YIDragScrollBarDelegate <NSObject>
@optional
- (void)dragScrollBarWillBeginDragging:(UIScrollView*)scrollView;
- (void)dragScrollBarWillEndDragging:(UIScrollView*)scrollView;

@end
