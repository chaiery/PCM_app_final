//
//  PatientViewController.m
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

#import "PatientViewController.h"

#import "PatientContainerView.h"
#import "PatientDetailView.h"
#import "PatientPlotViewController.h"
#import "DrugReferenceViewController.h"
#import "DrugReferenceLinkView.h"
#import "ObservationViewController.h"
#import "SVProgressHUD.h"
#import "MutationSearchTableViewController.h"
#import "Observation.h"
#import "DiagnosticReport.h"
#import "LOFOutlierPlotController.h"


@interface PatientViewController ()

@property (nonatomic, weak) PatientContainerView *containerView;
@property (nonatomic, strong) PatientDetailView *detailView;
@property (nonatomic, strong) MutationGeneTableView *mutationGeneTableView;
@property (nonatomic, strong) MutationGeneTableView *geneTableView;
@property (nonatomic, strong) PatientPlotViewController *pvc;
@property (nonatomic, strong) DrugReferenceViewController *drvc;
@property (nonatomic, strong) UIButton *buttonForPatient;
@property (nonatomic, strong) UIButton *buttonForLOF;
@property (nonatomic, strong) Patient *patient;
@property (nonatomic, strong) NSString *diseaseName;
//@property (nonatomic, strong) Observation *mutationObservation;
@property (nonatomic,strong) NSArray *mutationObservations;

@end



@implementation PatientViewController

- (instancetype)initWithPatient:(Patient *)patient
{
    self = [super init];
    if (self) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _patient = patient;
        self.title = [NSString stringWithFormat:@"%@ %@", [patient firstName], [patient lastName]];
        
        __block NSString *geneName, *mutation;
        _mutationObservations = [[_patient observations] allObjects];
        
        _mutationObservations = [_mutationObservations sortedArrayUsingSelector:@selector(compareObservation:)];
        [_mutationObservations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            geneName = [obj geneIdDisplay];
            mutation = [obj dnaSequenceVariation];
            
            if (!_diseaseName) {
                _diseaseName = [obj assessedCondition];
            }
            
            if (mutation && ![mutation isEqualToString:@"-"]) {
                //_mutationObservation = obj;
                
                *stop = YES;
            }
        }];
        
    /*  if ([_mutationObservations count]) {
            _drvc = [[DrugReferenceViewController alloc] initWithDisease:_diseaseName andGene:[_mutationObservation geneIdDisplay]];
        } */
    }
    return self;
}

- (void) loadView
{
    self.view = [[PatientContainerView alloc] init];
    _containerView = (PatientContainerView *)self.view;
    
    _detailView = [[PatientDetailView alloc] initWithPatient:_patient
                                                  andDisease:_diseaseName
                                      andMutationObservation:_mutationObservations];
  
    [_containerView setPatientDetailView:_detailView];
    
    
     _buttonForPatient = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     _buttonForPatient.translatesAutoresizingMaskIntoConstraints = NO;
     _buttonForPatient.layer.borderWidth = 1.0f;
     _buttonForPatient.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     _buttonForPatient.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0F);
     [_buttonForPatient setTitle:@"See All Gene Mutation" forState:UIControlStateNormal];
     [self.view addSubview:_buttonForPatient];
     [_buttonForPatient addTarget:self action:@selector(ClickForGene:) forControlEvents: UIControlEventTouchUpInside];
     
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_buttonForPatient
     attribute:NSLayoutAttributeBottomMargin
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeBottomMargin
     multiplier:1.0f
     constant:-300.0f]];
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_buttonForPatient
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f]];
    
     _buttonForLOF = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     _buttonForLOF.translatesAutoresizingMaskIntoConstraints = NO;
     _buttonForLOF.layer.borderWidth = 1.0f;
     _buttonForLOF.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     _buttonForLOF.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0F);
     [_buttonForLOF setTitle:@"See LOF" forState:UIControlStateNormal];
     [self.view addSubview:_buttonForLOF];
     [_buttonForLOF addTarget:self action:@selector(ClickForLOF:) forControlEvents: UIControlEventTouchUpInside];
    
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_buttonForLOF
                                                          attribute:NSLayoutAttributeBottomMargin
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1.0f
                                                           constant:-300.0f]];
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_buttonForLOF
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
  
    if (_drvc) {
        [self addChildViewController:_drvc];
        [_containerView setDrugReferenceLinkView:(DrugReferenceLinkView *)_drvc.view];
    }
    
}


- (void)viewDidLoad
{
    [SVProgressHUD showWithStatus:@"Building Plots"];
    
    _pvc = [[PatientPlotViewController alloc] initWithPatient:_patient
                                                   andDisease:_diseaseName
                                       andMutationObservation:_mutationObservations];
    [self addChildViewController:_pvc];
    [_containerView setPopulationPlotView:_pvc.view];
    
    
}


- (void) ClickForGene:(id) sender
{
 MutationSearchTableViewController *pvc= [[MutationSearchTableViewController alloc] initWithObservation:_mutationObservations
                                                                                            withDiseases:_diseaseName];

[self.navigationController pushViewController:pvc animated:YES];
}

- (void) ClickForLOF:(id) sender
{
    LOFOutlierPlotController *pvc= [[LOFOutlierPlotController alloc] initWithPatient:_patient
                                                                          andDisease:_diseaseName
                                                              andMutationObservation:_mutationObservations];
    
    [self.navigationController pushViewController:pvc animated:YES];
}

@end
