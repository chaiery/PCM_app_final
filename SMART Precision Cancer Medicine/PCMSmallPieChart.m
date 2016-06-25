//
//  PCMSmallPieChart.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/4/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "PCMSmallPieChart.h"
#import "CPTMutableLineStyle.h"
#import "CPTColor.h"

@implementation PCMSmallPieChart

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pieRadius = 140.0f;
        self.startAngle = M_PI_2;
        self.sliceDirection = CPTPieDirectionClockwise;
        self.labelRotationRelativeToRadius = NO;
        self.labelRotation = 0.0f;
        self.labelOffset = 5.0f;
        
        CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
        borderLineStyle.lineColor = [CPTColor blackColor];
        self.borderLineStyle = borderLineStyle;
    }
    return self;
}

@end
