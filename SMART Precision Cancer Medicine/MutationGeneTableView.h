//
//  MutationGeneTable.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/29.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"
#import "MutationChartPlotViewController.h"

@interface MutationGeneTableView : UITableView
- (instancetype)initWithDisease:(NSString *)disease andMutationObservation:(NSArray *)mutationObservations;
@end
