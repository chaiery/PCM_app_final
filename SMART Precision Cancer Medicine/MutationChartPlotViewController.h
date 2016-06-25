//
//  MutationChartPlotViewController.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/23.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Patient.h"
#import "Observation.h"

@interface MutationChartPlotViewController : UIViewController


@property (nonatomic) long smallChartPatientMutationIndex;
@property (nonatomic) long bigOuterChartPatientMutationIndex;
@property (nonatomic) long bigInnerChartPatientMutationIndex;

@property (nonatomic, readwrite) CGFloat geneChartHighlightOffset;
@property (nonatomic, readwrite) CGFloat mutationChartHighlightOffset;
 

- (instancetype) initWithObservation:(Observation *)mutationObservation withDiseases:(NSString *)disease;

@end
