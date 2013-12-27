YIDragScrollBar 1.1.1
=====================

Attaches draggable scroll bar on top of original UIScrollView for iOS5+, works like a drug.

<img src="https://raw.github.com/inamiy/YIDragScrollBar/master/Screenshots/screenshot1.png" alt="ScreenShot1" width="225px" style="width:225px;" />

- `YIDragScrollBar` uses [JRSwizzle](https://github.com/rentzsch/jrswizzle/) to extend `UIScrollView`'s functionality, and does not use any private APIs. 
- Installed UIScrollView subclass will add another dragging-scrollIndicator on top of it and temporarily hides original-scrollIndicator while dragging.
- Several application tests have been passed including:
	- vertical/horizontal dragging
	- zooming
	- device rotation
	- indicatorStyle (black & white)
	- contentInsets/scrollIndicatorInsets
	- UIScrollView subclasses (e.g. UITableView, UIWebView, UITextView)
	- never intercepts touches while original-scrollIndicator is hidden

Install via [CocoaPods](http://cocoapods.org/)
----------

```
pod 'YIDragScrollBar'
```
    
How to use
----------

Install in 1 second!

```
#import "YIDragScrollBar.h"

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [YIDragScrollBar install];
    
    // install to particular class only
    // [YIDragScrollBar installToUIScrollViewSubclass:[MyCustomScrollView class]];
}
```

Set `scrollView.dragScrollBarDelegate` to detect dragScrollBar began/ended. 

```

- (void)viewDidLoad
{
    ...

    self.scrollView.dragScrollBarDelegate = self;
}

- (void)dragScrollBarWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"dragScrollBar began");
}

- (void)dragScrollBarWillEndDragging:(UIScrollView *)scrollView
{
    NSLog(@"dragScrollBar ended");
}
```

License
-------
`YIDragScrollBar` is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license.

If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
