//
//  ObservationViewController.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutationChartPlotViewController.h"
#import "Observation.h"

@interface ObservationViewController : UIViewController

- (instancetype) initWithObservation:(Observation *)observation andWithDiseases:(NSString *)disease;

@end