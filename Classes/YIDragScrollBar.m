//
//  YIDragScrollBar.m
//  YIDragScrollBar
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "YIDragScrollBar.h"
#import "JRSwizzle.h"

@implementation YIDragScrollBar

+ (void)install
{
    [self installToUIScrollViewSubclass:[UIScrollView class]];
}

+ (void)installToUIScrollViewSubclass:(Class)c
{
    if (![c isSubclassOfClass:[UIScrollView class]]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"YIDragScrollBar must be installed to UIScrollView itself or subclass."];
        return;
    }
    
    [c jr_swizzleMethod:@selector(initWithFrame:)
             withMethod:@selector(yi_initWithFrame:)
                  error:NULL];
    
    [c jr_swizzleMethod:@selector(initWithCoder:)
             withMethod:@selector(yi_initWithCoder:)
                  error:NULL];
    
    [c jr_swizzleMethod:@selector(willMoveToSuperview:)
             withMethod:@selector(yi_willMoveToSuperview:)
                  error:NULL];
    
    [c jr_swizzleMethod:@selector(observeValueForKeyPath:ofObject:change:context:)
             withMethod:@selector(yi_observeValueForKeyPath:ofObject:change:context:)
                  error:NULL];
}

@end
