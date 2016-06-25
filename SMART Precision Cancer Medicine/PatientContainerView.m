//
//  PatientContainerView.m
//  SMART Genomics Precision Cancer Medicine
//
//  Created by Daniel Carbone on 9/23/14.
//  Copyright (c) 2014 Vanderbilt-Ingram Cancer Center. All rights reserved.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

#import "PatientContainerView.h"
#import "MutationGeneTableView.h"

@interface PatientContainerView()

@end

@implementation PatientContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return self;
}

#pragma mark - Patient Detail View

- (void) setPatientDetailView:(PatientDetailView *)patientView
{
    _patientDetailView = patientView;
    [self addSubview:_patientDetailView];
    [self layoutPatientDetailViewConstraints];
}


- (void) layoutPatientDetailViewConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[details]"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:@{@"details": _patientDetailView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[details]"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:@{@"details": _patientDetailView}]];
}


- (void)setPopulationPlotView:(UIView *)populationPlotView
{
    _populationPlotView = populationPlotView;
    [self addSubview:_populationPlotView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_populationPlotView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_patientDetailView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:20.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_populationPlotView]|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_populationPlotView)]];
}

- (void)setDrugReferenceLinkView:(DrugReferenceLinkView *)drugReferenceLinkView
{
    _drugReferenceLinkView = drugReferenceLinkView;
    [self addSubview:_drugReferenceLinkView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[drugView]-|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:@{@"drugView": _drugReferenceLinkView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[drugView]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"drugView": _drugReferenceLinkView}]];
}

@end