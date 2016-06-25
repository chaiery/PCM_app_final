//
//  ObservationContainerView.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "ObservationContainerView.h"
#import "GeneDetailView.h"
@interface ObservationContainerView()

@end

@implementation ObservationContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return self;
}

- (void) setGeneDetailView:(GeneDetailView *)geneDetailView
{
    _geneDetailView = geneDetailView;
    [self addSubview:_geneDetailView];
    [self layoutGeneDetailViewConstraints];
}


- (void) layoutGeneDetailViewConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[details]"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:@{@"details": _geneDetailView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[details]"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:@{@"details": _geneDetailView}]];

}


- (void)setMutationPlotView:(UIView *)mutationPlotView
{
    _mutationPlotView = mutationPlotView;
    [self addSubview:_mutationPlotView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_mutationPlotView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_geneDetailView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:20.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mutationPlotView]|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_mutationPlotView)]];
}


@end
