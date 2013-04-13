//
//  MenuViewController.m
//  YIDragScrollBarDemo
//
//  Created by Yasuhiro Inami on 2013/04/13.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "MenuViewController.h"
#import "ScrollViewController.h"
#import "WebViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:@"ScrollView"]) {
        
        ScrollViewController* vc = (ScrollViewController*)segue.destinationViewController;
        
        const int c = 1; //3;
        
        if ([segue.identifier isEqualToString:@"ScrollViewVerticalSegue"]) {
            vc.defaultContentSize = CGSizeMake(320*c, 1000*c);
        }
        else if ([segue.identifier isEqualToString:@"ScrollViewHorizontalSegue"]) {
            vc.defaultContentSize = CGSizeMake(1000*c, 320*c);
        }
        else if ([segue.identifier isEqualToString:@"ScrollViewBothSegue"]) {
            vc.defaultContentSize = CGSizeMake(1000*c, 1000*c);
        }
        else if ([segue.identifier isEqualToString:@"ScrollViewBothWithInsetsSegue"]) {
            vc.defaultContentSize = CGSizeMake(1000*c, 1000*c);
            vc.defaultContentInsets = UIEdgeInsetsMake(20, 40, 60, 80);
            vc.defaultScrollIndicatorInsets = UIEdgeInsetsMake(10, 20, 30, 40);
            vc.defaultDraggingVerticalScrollIndicatorImageInsets = UIEdgeInsetsMake(0, 10, 0, 10);   // only uses left & right
            vc.defaultDraggingHorizontalScrollIndicatorImageInsets = UIEdgeInsetsMake(40, 0, 20, 0);   // only uses top & bottom
        }
        else if ([segue.identifier isEqualToString:@"ScrollViewWhiteStyleSegue"]) {
            vc.defaultContentSize = CGSizeMake(320*c, 1000*c);
            vc.defaultIndicatorStyle = UIScrollViewIndicatorStyleWhite;
        }
    }
}

// for iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
