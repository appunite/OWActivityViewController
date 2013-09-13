//
// OWActivityView.h
// OWActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "OWActivityView.h"
#import "OWActivityViewController.h"

@implementation OWActivityView

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _activities = activities;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 80.f, frame.size.width, 80.f)];
            [_backgroundView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f]];
            [self addSubview:_backgroundView];
        }
        
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 8, frame.size.width, self.frame.size.height - 104)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
        
        NSInteger index = 0;
        NSInteger row = -1;
        NSInteger page = -1;
        for (OWActivity *activity in _activities) {
            NSInteger col;
            
            col = index%3;
            if (index % 3 == 0) row++;
            if (index % 9 == 0) {
                row = 0;
                page++;
            }
            
            UIView *view = [self viewForActivity:activity
                                           index:index
                                               x:(20 + col*80 + col*20) + page * frame.size.width
                                               y:0];
            CGRect frame = view.frame;
            frame.origin.y = CGRectGetHeight(_scrollView.frame) - CGRectGetHeight(view.frame);
            [_scrollView addSubview:view];
            index++;
        }
        _scrollView.contentSize = CGSizeMake((page +1) * frame.size.width, _scrollView.frame.size.height);
        _scrollView.pagingEnabled = YES;
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 84, frame.size.width, 10)];
        _pageControl.numberOfPages = page + 1;
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        if (_pageControl.numberOfPages <= 1) {
            _pageControl.hidden = YES;
            _scrollView.scrollEnabled = NO;
        }
    }
    return self;
}

- (UIView *)viewForActivity:(OWActivity *)activity index:(NSInteger)index x:(NSInteger)x y:(NSInteger)y
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, 62, 62)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 0, 59, 59);
    button.tag = index;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:activity.image forState:UIControlStateNormal];
    if (activity.backgroundNormal) {
        [button setBackgroundImage:activity.backgroundNormal forState:UIControlStateNormal];
    }
    if (activity.backgroundActive) {
        [button setBackgroundImage:activity.backgroundActive forState:UIControlStateHighlighted];
    }
    if (activity.backgroundOff) {
        [button setBackgroundImage:activity.backgroundOff forState:UIControlStateDisabled];
    }
    button.accessibilityLabel = activity.title;
    [view addSubview:button];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _scrollView.frame;
    frame.origin.y = self.frame.size.height - 67;
    _scrollView.frame = frame;
}

#pragma mark -
#pragma mark Button action

- (void)cancelButtonPressed
{
    [_activityViewController dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(didCancelActivityView)]) {
        [_delegate didCancelActivityView];
    }
}

- (void)buttonPressed:(UIButton *)button
{
    OWActivity *activity = [_activities objectAtIndex:button.tag];
    activity.activityViewController = _activityViewController;
    
    if (activity.actionBlock) {
        [self.activityViewController dismissViewControllerAnimated:YES completion:^{
            BOOL canPerform = NO;
            if ([_delegate respondsToSelector:@selector(shouldStartActivity:)]) {
                // ask if request is still valid
                BOOL shouldStartActivity = [_delegate shouldStartActivity:activity];
                if (shouldStartActivity) {
                    canPerform = YES;
                } else {
                    [self cancelButtonPressed];
                }
            } else {
                canPerform = YES;
            }
            if (canPerform) {
                // prepare to run
                if ([_delegate respondsToSelector:@selector(willPerformActivity:)]) {
                    [_delegate willPerformActivity:activity];
                }
                activity.actionBlock(activity, _activityViewController);
            }
        }];
        
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -

- (void)pageControlValueChanged:(UIPageControl *)pageControl
{
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

@end
