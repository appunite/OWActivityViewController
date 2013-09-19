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

#import <UIKit/UIKit.h>
#import "OWActivity.h"

@protocol OWActivityViewDelegate <NSObject>

@optional
- (void)didCancelActivityView;
- (BOOL)shouldStartActivity:(OWActivity *)activity;
- (void)willPerformActivity:(OWActivity *)activity;
- (void)didPerformActivity:(OWActivity *)activity;

@end


@interface OWActivityItemView : UIView

@property (nonatomic, strong) UILabel *label;

@end


@interface OWActivityView : UIView <UIScrollViewDelegate> {
    UIPageControl *_pageControl;
    NSMutableArray *_activityViews;
    NSMutableArray *_activityLabels;
    NSInteger _userRowCount;
}

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *activities;
@property (weak, nonatomic) OWActivityViewController *activityViewController;
@property (strong, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) id<OWActivityViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger itemsPerRow;
@property (nonatomic, assign, readonly) NSInteger rowsPerPage;
@property (nonatomic, assign) BOOL showLabels;

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities;
- (void)setPerPageRows:(NSInteger)rows columns:(NSInteger)columns;

@end
