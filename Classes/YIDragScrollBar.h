//
//  YIDragScrollBar.h
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIScrollView+YIDragScrollBar.h"

@interface YIDragScrollBar : NSObject

+ (void)install;    // installs to all of UIScrollView
+ (void)installToUIScrollViewSubclass:(Class)c;

@end
