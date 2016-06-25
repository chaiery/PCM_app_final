//
//  GeneDetailView.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "GeneDetailView.h"
#import "PatientDetailLabel.h"
#import "PatientViewTitleLabel.h"

@interface GeneDetailView ()
@property (nonatomic, strong) PatientViewTitleLabel *viewTitle;
//@property (nonatomic, strong) PatientDetailLabel *genderDOB;
//@property (nonatomic, strong) PatientDetailLabel *diseaseLabel;
//@property (nonatomic, strong) PatientDetailLabel *detectedMutationLabel;

@end


@implementation GeneDetailView

- (instancetype)initWithGene:(NSString *)gene
{
    self = [super init];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        _viewTitle = [[PatientViewTitleLabel alloc] initWithText:[NSString stringWithFormat:@"%@", gene]];
        _viewTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_viewTitle];
    }
    return self;
}

- (void) layoutSubviews
{
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_viewTitle]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_viewTitle)]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_viewTitle]|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_viewTitle)]];
    [super layoutSubviews];
}


@end

