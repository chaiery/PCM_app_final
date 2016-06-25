//
//  ObservationContainerView.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneDetailView.h"
#import "ObservationContainerView.h"
@interface ObservationContainerView : UIView
@property (nonatomic, strong) GeneDetailView *geneDetailView;
@property (nonatomic, weak) UIView *mutationPlotView;
@end
