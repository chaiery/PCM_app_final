//
//  LOFOutlierPlotController.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/8/6.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"
#import <CorePlot-CocoaTouch.h>

@interface LOFOutlierPlotController : UIViewController <CPTPlotDataSource>
{
@private
CPTXYGraph * barChart ;
}

@property ( readwrite , retain , nonatomic ) NSTimer *timer;

- (instancetype)initWithPatient:(Patient *)patient andDisease:(NSString *)disease andMutationObservation:(NSArray *)mutationObservations;

- (void)initializeData;
@end
