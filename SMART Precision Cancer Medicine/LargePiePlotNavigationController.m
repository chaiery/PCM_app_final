//
//  LargePiePlotNavigationController.m
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

#import "LargePiePlotNavigationController.h"

#import "PCMOuterPieChart.h"
#import "PCMInnerPieChart.h"
#import "PCMXYGraph.h"
#import "PCMGraphHostingView.h"

@interface LargePiePlotNavigationController ()

@property (nonatomic, strong) UIViewController *pieChartHostController;
@property (nonatomic, strong) PCMOuterPieChart *outerPieChart;
@property (nonatomic, strong) PCMInnerPieChart *innerPieChart;

@end

@implementation LargePiePlotNavigationController

- (id) init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        _pieChartHostController = [[UIViewController alloc] init];
        _pieChartHostController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                                     style:UIBarButtonItemStylePlain
                                                                                                    target:self
                                                                                                    action:@selector(closeSelf:)];
        self.viewControllers = @[_pieChartHostController];
    }
    return self;
}

- (void) renderBigGenePieChartWithIdentifier:(NSString *)identifier
                               andDataSource:(id<CPTPieChartDataSource>)pieChartDataSource
                                 andDelegate:(id<CPTPieChartDelegate>)delegate
                                    andTitle:(NSString *)title
{
    [self popToRootViewControllerAnimated:NO];
    
    _pieChartHostController.title = title;
    if (!_outerPieChart)
    {
        PCMGraphHostingView *graphHostingView = [[PCMGraphHostingView alloc] init];
        [_pieChartHostController.view addSubview:graphHostingView];
        
        PCMXYGraph *graph = [[PCMXYGraph alloc] init];
        [graphHostingView setHostedGraph:graph];
        graph.plotAreaFrame.paddingTop = 40.0f;
        
        _outerPieChart = [[PCMOuterPieChart alloc] init];
        _innerPieChart = [[PCMInnerPieChart alloc] init];

        [graph addPlot:_outerPieChart];
        [graph addPlot:_innerPieChart];
        
        [_pieChartHostController.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[graph(>=500)]|"
                                                 options:NSLayoutFormatAlignAllCenterX
                                                 metrics:nil
                                                   views:@{@"graph": graphHostingView}]];
        [_pieChartHostController.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[graph(>=500)]|"
                                                 options:NSLayoutFormatAlignAllCenterY
                                                 metrics:nil
                                                   views:@{@"graph": graphHostingView}]];
    }
    
    _outerPieChart.identifier = [NSString stringWithFormat:@"BIG%@OUTER", identifier];
    _outerPieChart.delegate = delegate;
    _outerPieChart.dataSource = pieChartDataSource;
    
    _innerPieChart.identifier = [NSString stringWithFormat:@"BIG%@INNER", identifier];
    _innerPieChart.delegate = delegate;
    _innerPieChart.dataSource = pieChartDataSource;
    
    [_outerPieChart reloadData];
    [_innerPieChart reloadData];
}

- (void)closeSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
