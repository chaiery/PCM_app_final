//
//  PCMXYGraph.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/4/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "PCMXYGraph.h"

#import "CPTFill.h"
#import "CPTColor.h"
#import "CPTPlotAreaFrame.h"
#import "CPTMutableTextStyle.h"

@implementation PCMXYGraph

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.borderLineStyle = nil;
        self.paddingTop = 0;
        self.paddingRight = 0;
        self.paddingLeft = 0;
        self.paddingBottom = 0;
        
        self.axisSet = nil;
        self.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
        
        self.plotAreaFrame.masksToBorder = YES;
        self.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
        self.plotAreaFrame.borderLineStyle = nil;
        self.plotAreaFrame.borderWidth = 0.0f;
        self.plotAreaFrame.paddingBottom = 0;
        self.plotAreaFrame.paddingLeft = 0;
        self.plotAreaFrame.paddingRight = 0;
        self.plotAreaFrame.paddingTop = 15.f;
        
        CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
        [textStyle setFontSize:18.0f];
        self.titleTextStyle = textStyle;
    }
    return self;
}

@end
