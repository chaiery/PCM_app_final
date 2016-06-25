//
//  PatientDetailView.m
//  SMART Genomics Precision Cancer Medicine
//
//  Created by Daniel Carbone on 8/29/14.
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

#import "PatientDetailView.h"

#import "PatientViewTitleLabel.h"
#import "PatientDetailLabel.h"

@interface PatientDetailView ()

@property (nonatomic, strong) PatientViewTitleLabel *viewTitle;
@property (nonatomic, strong) PatientDetailLabel *genderDOB;
@property (nonatomic, strong) PatientDetailLabel *diseaseLabel;
@property (nonatomic, strong) PatientDetailLabel *detectedMutationLabel;

@end

@implementation PatientDetailView

- (instancetype)initWithPatient:(Patient *)patient andDisease :(NSString *)disease andMutationObservation:(NSArray *)mutationObservations
{
    self = [super init];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        _viewTitle = [[PatientViewTitleLabel alloc] initWithText:[NSString stringWithFormat:@"%@ %@ (MRN: %@)", [patient firstName], [patient lastName],[patient mrn]]];
        _viewTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_viewTitle];
        
        _genderDOB = [[PatientDetailLabel alloc] initWithText:[NSString stringWithFormat:@"%@, %@", [patient gender], [patient birthDate]]];
        _genderDOB.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_genderDOB];
        
        _diseaseLabel = [[PatientDetailLabel alloc] initWithText:[NSString stringWithFormat:@"Diagnosis: %@", disease]];
        _diseaseLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_diseaseLabel];
        
        _detectedMutationLabel = [[PatientDetailLabel alloc] init];
        _detectedMutationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_detectedMutationLabel];
        
        _detectedMutationLabel.numberOfLines = 0;
        
/*
        __block NSMutableString *text = [[NSMutableString alloc] init];
        
        if ([mutationObservations count]) {
            [text appendFormat:@"Mutation: "];
            [mutationObservations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [text appendFormat:@"%@\n ",[obj geneIdDisplay]];
            }];
            
            _detectedMutationLabel.text = [NSString stringWithFormat:@"%@",text];

        }else {
            _detectedMutationLabel.text = @"No mutations detected in tested genes.";
        }*/

    }
    return self;
}

- (void) layoutSubviews
{
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_viewTitle]-[_genderDOB]-[_diseaseLabel]-[_detectedMutationLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_viewTitle, _genderDOB, _diseaseLabel, _detectedMutationLabel)]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_viewTitle]|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_viewTitle)]];
    [super layoutSubviews];
}


@end
