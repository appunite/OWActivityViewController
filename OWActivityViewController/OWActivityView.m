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

#import <QuartzCore/QuartzCore.h>

@implementation OWActivityItemView

- (void)setLabel:(UILabel *)label {
    if (_label) {
        [_label removeFromSuperview];
    }
    _label = label;
    [self addSubview:label];
}

@end


@implementation OWActivityView

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _activities = activities;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 90.f, frame.size.width, 90.f)];
            [_backgroundView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
            [self addSubview:_backgroundView];
        }
        
        _activityViews = [[NSMutableArray alloc] initWithCapacity:activities.count];
        
        _itemsPerRow = 3;
        _rowsPerPage = 3;
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"OWActivityViewController.bundle/Button"] stretchableImageWithLeftCapWidth:22 topCapHeight:47] forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedStringFromTable(@"button.cancel", @"OWActivityViewController", @"Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_cancelButton];
        
        [self setPerPageRows:_rowsPerPage columns:_itemsPerRow];
    }
    return self;
}


- (void)setPerPageRows:(NSInteger)rows columns:(NSInteger)columns {
    _itemsPerRow = columns;
    _rowsPerPage = rows;
    
    // rebuilding views from scratch, TODO modify them instead
    CGRect frame = self.frame;
    [_scrollView removeFromSuperview];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 8, frame.size.width, self.frame.size.height - 104)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    
    NSInteger index = 0;
    NSInteger row = -1;
    NSInteger page = -1;
    
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _activityViews = [[NSMutableArray alloc] initWithCapacity:_activities.count];
    for (OWActivity *activity in _activities) {
        NSInteger col;
        
        col = index%_itemsPerRow;
        if (index % _itemsPerRow == 0) row++;
        if (index % (_itemsPerRow*_rowsPerPage) == 0) {
            row = 0;
            page++;
        }
        
        UIView *view = [self viewForActivity:activity
                                       index:index
                                         row:row
                                         col:col
                                        page:page];
        
        [_activityViews addObject:view];
        CGRect frame = view.frame;
        frame.origin.y = CGRectGetHeight(_scrollView.frame) - CGRectGetHeight(view.frame);
        [_scrollView addSubview:view];
        index++;
    }
    _scrollView.contentSize = CGSizeMake((page +1) * frame.size.width, _scrollView.frame.size.height);
    _scrollView.pagingEnabled = YES;
    
    [_pageControl removeFromSuperview];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 84, frame.size.width, 10)];
    _pageControl.numberOfPages = page + 1;
    [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    
    if (_pageControl.numberOfPages <= 1) {
        _pageControl.hidden = YES;
        _scrollView.scrollEnabled = NO;
    }
    
    
    
    [self setNeedsLayout];
    
}


- (OWActivityItemView *)viewForActivity:(OWActivity *)activity index:(NSInteger)index row:(NSInteger)row col:(NSInteger)col page:(NSInteger)page
{
    OWActivityItemView *view = [[OWActivityItemView alloc] initWithFrame:[self rectForActivityViewAtIndex:index row:row col:col page:page]];//CGRectMake(x, y, 62, 62)];
    
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 63, 80, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:221.f/255.f alpha:1.f];
    label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = activity.title;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    label.numberOfLines = 0;
    [label setNumberOfLines:0];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = round((view.frame.size.width - frame.size.width) / 2.0f);
    label.frame = frame;
    [view setLabel:label];
    [view.label setHidden:!_showLabels];
    
    return view;
}

- (CGRect)rectForActivityViewAtIndex:(NSInteger)index row:(NSInteger)row col:(NSInteger)col page:(NSInteger)page {
    NSInteger width = [self itemWidth];
    NSInteger height = [self itemHeight];
    CGFloat gridHeight = height + [self itemVSpacing];
    return CGRectMake((20 + col*width + col*20) + page * CGRectGetWidth(self.frame), row*gridHeight, width, height);
}

- (CGFloat)itemWidth {
    return 80.f;
}

- (CGFloat)itemHeight {
    return _showLabels ? 75.f : 62.f;
}

- (CGFloat)itemVSpacing {
    return 15.f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = [self itemHeight];
    CGFloat vSpace = [self itemVSpacing];
    CGFloat gridHeight = height + vSpace;
    
    NSInteger index = 0;
    NSInteger row = -1;
    NSInteger page = -1;
    NSInteger rowCount = 0;
    
    for (UIView *view in _activityViews) {
        NSInteger col;
        col = index%_itemsPerRow;
        if (index % _itemsPerRow == 0) {
            row++;
        }
        if (index % (_itemsPerRow*_rowsPerPage) == 0) {
            row = 0;
            page++;
        }
        
        rowCount = MAX(row+1, rowCount);
        [view setFrame:[self rectForActivityViewAtIndex:index row:row col:col page:page]];
        index++;
    }
    
    CGFloat cancelButtonOffset = 57.f;
    
    CGRect frame = _scrollView.frame;
    frame.origin.y = self.frame.size.height - rowCount*gridHeight - cancelButtonOffset;
    frame.size.height = rowCount*gridHeight;
    _scrollView.frame = frame;
    _scrollView.contentSize = CGSizeMake((page +1) * frame.size.width, _scrollView.frame.size.height);
    
    frame = _backgroundView.frame;
    frame.origin.y = self.frame.size.height - rowCount*gridHeight - 20.f - cancelButtonOffset;
    frame.size.height = self.frame.size.height - frame.origin.y + cancelButtonOffset;
    _backgroundView.frame = frame;
    
    frame = _pageControl.frame;
    frame.origin.y = self.frame.size.height - rowCount*gridHeight - 10.f - frame.size.height/2.f - cancelButtonOffset;
    _pageControl.frame = frame;
    
    _cancelButton.frame = CGRectMake(22, CGRectGetMaxY(_scrollView.frame)+2, 276, 47);
    [_cancelButton setHidden:NO];
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

#pragma mark properties

- (void)setShowLabels:(BOOL)showLabels {
    _showLabels = showLabels;
    for (OWActivityItemView *view in _activityViews) {
        [view.label setHidden:!_showLabels];
    }
    [self setNeedsLayout];
}

@end
