//
//  PCMGraphHostingView.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/4/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "PCMGraphHostingView.h"

@implementation PCMGraphHostingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        self.allowPinchScaling = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
