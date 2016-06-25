//
//  PCMOuterPieChart.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/5/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "PCMOuterPieChart.h"

#import "CPTMutableLineStyle.h"
#import "CPTColor.h"

@implementation PCMOuterPieChart

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pieRadius = 325.0f;
        self.pieInnerRadius = 225.0f;
        self.startAngle = M_PI_2;
        self.sliceDirection = CPTPieDirectionClockwise;
        self.labelRotationRelativeToRadius = YES;
        self.labelRotation = 0.0f;
        self.labelOffset = -90.0f;
        self.borderLineStyle = [[CPTMutableLineStyle alloc] init];
        [(CPTMutableLineStyle *)self.borderLineStyle setLineColor:[CPTColor blackColor]];
        self.centerAnchor = CGPointMake(0.5f, 0.48f);
    }
    return self;
}

@end
