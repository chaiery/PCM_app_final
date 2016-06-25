//
//  PatientPlotViewController.m
//  SMART Genomics Precision Cancer Medicine
//
//  Created by Daniel Carbone on 9/25/14.
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

#import "PatientPlotViewController.h"
#import "MutationChartPlotViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "SVProgressHUD.h"

#import "GeneDataHelper.h"
#import "MutationDataHelper.h"

#import "LargePiePlotNavigationController.h"

#import "PCMGraphHostingView.h"
#import "PCMXYGraph.h"
#import "PCMSmallPieChart.h"
#import "PCMMediumPieChart.h"

#import "RICAppDelegate.h"

typedef enum {
    pvcPopulationGeneObservations,
    pvcPopulationPatientLookup,
    pvcPopulationPatientObservationLookup,
} PopulationDataQueryStatus;

@interface PatientPlotViewController ()<UIWebViewDelegate, CPTPieChartDelegate, CPTPieChartDataSource, CPTLegendDelegate, CPTPlotSpaceDelegate>

@property (nonatomic, strong) UIButton *buttonForPatient;
@property (nonatomic, strong) NSString *disease;
@property (nonatomic, weak) NSArray *mutationObservations;
@property (nonatomic, strong) NSMutableArray *geneWithMutations;
@property (nonatomic, strong) NSMutableArray *mutationDNASequenceVariations;
@property (nonatomic, strong) NSMutableArray *mutationAlleleNames;
@property (nonatomic, strong) NSMutableArray *mutationMaps;
@property (nonatomic, strong) NSMutableDictionary *alleleNameCount;

@property (nonatomic, strong) NSMutableDictionary *chartGeneData;
@property (nonatomic, strong) NSMutableDictionary *bigOuterChartGeneData;
@property (nonatomic, strong) NSMutableDictionary *bigInnerChartGeneData;
@property (nonatomic, strong) NSMutableArray *geneList;
@property (nonatomic, strong) NSMutableArray *bigOuterGeneList;
@property (nonatomic, strong) NSMutableArray *bigInnerGeneList;
@property (nonatomic) int largestGene;

@property (nonatomic, strong) NSMutableArray *chartMutationDatas;
@property (nonatomic, strong) NSMutableArray *bigOuterChartMutationDatas;
@property (nonatomic, strong) NSMutableArray *bigInnerChartMutationDatas;
@property (nonatomic, strong) NSMutableArray *mutationLists;
@property (nonatomic, strong) NSMutableArray *bigOuterMutationLists;
@property (nonatomic, strong) NSMutableArray *bigInnerMutationLists;
@property (nonatomic) int largestMutation;

@property (nonatomic, strong) PCMSmallPieChart *smallGeneChart;
@property (nonatomic, strong) PCMMediumPieChart *mediumGeneChart;
@property (nonatomic, strong) PCMSmallPieChart *smallMutationChart;
@property (nonatomic, strong) PCMMediumPieChart *mediumMutationChart;

@property (nonatomic, strong) PCMXYGraph *geneGraph;
@property (nonatomic, weak) CPTPieChart *currentGeneChart;


@property (nonatomic, strong) UIView *rootView;

@property (nonatomic, strong) PCMGraphHostingView *genePlotHostingView;
//@property (nonatomic, strong) PCMGraphHostingView *mutationPlotHostingView;

@property (nonatomic, strong) NSLayoutConstraint *geneChartWidthConstraint;

@property (nonatomic, strong) NSMutableArray *geneChartOnlyPortraitConstraints;
@property (nonatomic, strong) NSMutableArray *geneChartOnlyLandscapeConstraints;

@property (nonatomic, strong) NSMutableArray *bothChartPortraitConstraints;
@property (nonatomic, strong) NSMutableArray *bothChartLandscapeConstraints;

@property (nonatomic, strong) UIViewController *webViewController;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *currentURLString;

@property (nonatomic, weak) NSManagedObjectContext *moc;
@property (nonatomic, weak) EntitySearchService *entitySearchService;

@property (nonatomic) BOOL plotsInitialized;

- (void) closeLargeChart:(id)sender;

@end

static GeneDataHelper *geneDataHelper;
static MutationDataHelper *mutationDataHelper;

static LargePiePlotNavigationController *largePiePlotNavController;

@implementation PatientPlotViewController

@synthesize geneChartHighlightOffset;
@synthesize mutationChartHighlightOffset;

- (instancetype)initWithPatient:(Patient *)patient andDisease:(NSString *)disease andMutationObservation:(NSArray *)mutationObservations
{
    self = [super init];
    if (self) {
        
        _plotsInitialized = NO;
        
        // There MUST be a better way to do this.....
        RICAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _entitySearchService = appDelegate.entitySearchService;
        
        if (!geneDataHelper) {
            geneDataHelper = [[GeneDataHelper alloc] init];
        }
        
        if (!mutationDataHelper) {
            mutationDataHelper = [[MutationDataHelper alloc] init];
        }
        
        if (!largePiePlotNavController) {
            largePiePlotNavController = [[LargePiePlotNavigationController alloc] init];
        }
        
        _disease = disease;
        _mutationObservations = mutationObservations;
        _largestGene = 0;
        _largestMutation = 0;
        _webViewController = [[UIViewController alloc] init];
        _webView = [[UIWebView alloc] init];
        
        
        _webView.delegate = self;
        _webViewController.view = _webView;
        _webViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                                style:UIBarButtonItemStylePlain
                                                                                               target:self
                                                                                               action:@selector(closeLargeChart:)];
        
        geneChartHighlightOffset = 0;
        //mutationChartHighlightOffset = 0;
        
        [self initializeGraphData];
    }
    return self;
}

#pragma mark - View methods

- (void)loadView
{
    _rootView = [[UIView alloc] init];
    _rootView.translatesAutoresizingMaskIntoConstraints = NO;
    _rootView.backgroundColor = [UIColor whiteColor];
    self.view = _rootView;

}

                 


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_plotsInitialized == NO) {
        [SVProgressHUD showWithStatus:@"Initializing Graphs"];
        if ([_geneList count] > 0) {
            [self createPopulationGeneGraph];
            _plotsInitialized = YES;
            [self highlightSlice];
        } else {
            
        }
        [SVProgressHUD dismiss];
    }
}


- (void)viewWillLayoutSubviews
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (_genePlotHostingView) {
            
            if (_currentGeneChart) {
                [_geneGraph removePlot:_currentGeneChart];
            }
            
            _currentGeneChart = _smallGeneChart;
            [_geneGraph addPlot:_currentGeneChart];
            
            [_rootView.superview removeConstraints:_geneChartOnlyLandscapeConstraints];
            [_rootView.superview addConstraints:_geneChartOnlyPortraitConstraints];
            
        }
    } else {
        if (_genePlotHostingView) {
            
            if (_currentGeneChart) {
                [_geneGraph removePlot:_currentGeneChart];
            }
            _currentGeneChart = _mediumGeneChart;
            
            [_geneGraph addPlot:_currentGeneChart];
            [_rootView.superview removeConstraints:_geneChartOnlyPortraitConstraints];
            [_rootView.superview addConstraints:_geneChartOnlyLandscapeConstraints];
            
        }
    }
}

#pragma mark - Population Graph Views

- (void)highlightSlice
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CPTAnimation animate:self
                     property:@"geneChartHighlightOffset"
                         from:0.0
                           to:20.0
                     duration:0.75
               animationCurve:CPTAnimationCurveCubicOut
                     delegate:nil];
    });
}

- (void)setGeneChartHighlightOffset:(CGFloat)newOffset
{
    if (newOffset != geneChartHighlightOffset) {
        geneChartHighlightOffset = newOffset;
        
        [_geneGraph reloadData];
    }
}


- (void)initializeGraphData
{
    NSArray *geneList = [_entitySearchService getAllGenesForDisease:_disease];
    if (nil == geneList || [geneList count] == 0) {
        [SVProgressHUD showErrorWithStatus:@"Unable to get list of genes from CoreData, please give device to developer for debugging."];
    } else {
        __block NSNumber *itemCount;
        __block BOOL errorEncountered = NO;
        __block int minGeneSize = 10,  itemCountInt;
       // __block int minMutationSize = 10;
        _geneList = [[NSMutableArray alloc] init];
        _bigOuterGeneList = [[NSMutableArray alloc] init];
        _bigInnerGeneList = [[NSMutableArray alloc] init];
        
        _chartGeneData = [[NSMutableDictionary alloc] init];
        _bigOuterChartGeneData = [[NSMutableDictionary alloc] init];
        _bigInnerChartGeneData = [[NSMutableDictionary alloc] init];
        _geneWithMutations = [[NSMutableArray alloc] init];
        _mutationMaps = [[NSMutableArray alloc] init];
        
        geneList = [[geneList arrayByAddingObject:@"Not Detected"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [geneList enumerateObjectsUsingBlock:^(id gene, NSUInteger idx, BOOL *stop) {
            
            if ([gene isEqualToString:@"Not Detected"]) {
                itemCount = [_entitySearchService countPatientsWithNoMutationsDetectedInDisease:_disease];
            } else {
                itemCount = [_entitySearchService countPatientsWithAnyMutationOnGene:gene inDisease:_disease];
            }
            
            if ((itemCountInt = [itemCount intValue]) >0) {
                [_geneList addObject:gene];
                [_chartGeneData setObject:itemCount forKey:gene];
                
                if (itemCountInt > _largestGene) {
                    _largestGene = itemCountInt;
                }
                
                if (itemCountInt > minGeneSize) {
                    [_bigOuterChartGeneData setObject:itemCount forKey:gene];
                    [_bigOuterGeneList addObject:gene];
                }
                else {
                    [_bigInnerChartGeneData setObject:itemCount forKey:gene];
                    [_bigInnerGeneList addObject:gene];
                }

            }
            
        }];
        
        
        if (!errorEncountered && [_geneList count] > 0) {
            
            if ([_mutationObservations count]){
                [_mutationObservations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [_geneWithMutations addObject:[obj geneIdDisplay]];
                }];
                
            }
            if (nil == _geneWithMutations) {
                [_geneWithMutations addObject:@"Not Detected"];
            }
            //__block NSMutableArray *smallChartPatientMutationIndexTransfer;
            _smallChartPatientMutationIndex = [[NSMutableArray alloc] init];
            _bigOuterGeneChartWithMutationIndex = [[NSMutableArray alloc] init];
            _bigInnerGeneChartWithMutationIndex = [[NSMutableArray alloc] init];
            
            [_geneWithMutations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_smallChartPatientMutationIndex addObject:[NSNumber numberWithLong:[_geneList indexOfObject:obj]]];
            } ];
            [_geneWithMutations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [_bigOuterGeneChartWithMutationIndex addObject:[NSNumber numberWithLong:[_bigOuterGeneList indexOfObject:obj]]];
            } ];
            [_geneWithMutations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [_bigInnerGeneChartWithMutationIndex addObject:[NSNumber numberWithLong:[_bigInnerGeneList indexOfObject:obj]]];
            } ];
            

        }
    }
}


- (void) createPopulationGeneGraph
{
    _genePlotHostingView = [[PCMGraphHostingView alloc] init];
    [_rootView addSubview:_genePlotHostingView];
    
    _geneGraph = [[PCMXYGraph alloc] init];
    [_genePlotHostingView setHostedGraph:_geneGraph];
    _geneGraph.title = [NSString stringWithFormat:@"Mutated Genes Observed in %@", _disease];
    
    _smallGeneChart = [[PCMSmallPieChart alloc] init];
    _mediumGeneChart = [[PCMMediumPieChart alloc] init];
    
    _smallGeneChart.identifier = @"GENE";
    _smallGeneChart.delegate = self;
    _smallGeneChart.dataSource = self;
    _mediumGeneChart.identifier = @"GENE";
    _mediumGeneChart.delegate = self;
    _mediumGeneChart.dataSource = self;
    
    _geneChartOnlyPortraitConstraints = [[NSMutableArray alloc] init];
    [_geneChartOnlyPortraitConstraints addObject:
     [NSLayoutConstraint constraintWithItem:_rootView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:400.0f]];
    [_geneChartOnlyPortraitConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_genePlotHostingView]|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_genePlotHostingView)]];
    [_geneChartOnlyPortraitConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_genePlotHostingView]|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_genePlotHostingView)]];
    
    
    _geneChartOnlyLandscapeConstraints = [[NSMutableArray alloc] init];
    [_geneChartOnlyLandscapeConstraints addObject:
     [NSLayoutConstraint constraintWithItem:_rootView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:500.0f]];
    [_geneChartOnlyLandscapeConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_genePlotHostingView]|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_genePlotHostingView)]];
    [_geneChartOnlyLandscapeConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_genePlotHostingView]|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_genePlotHostingView)]];
}

#pragma mark - CPTPieChartDataSource implementation

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    id identifier = plot.identifier;
    int count = 0;
    
    if (identifier)
    {
        if ([identifier isEqualToString:@"GENE"]) {
            count = (int)[_chartGeneData count];
            
        } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
            count = (int)[_bigOuterChartGeneData count];
        } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
            count = (int)[_bigInnerChartGeneData count];
        }
    }

    return count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id identifier = plot.identifier;
    
    NSNumber *number;
    
    if (identifier) {
        if ([identifier isEqualToString:@"GENE"]) {
            number = _chartGeneData[_geneList[index]];
        } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
            number = _bigOuterChartGeneData[_bigOuterGeneList[index]];
        } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
            number = _bigInnerChartGeneData[_bigInnerGeneList[index]];
        }
    }
    
    return number;
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    id identifier = pieChart.identifier;
    NSString *gene;
    NSUInteger geneIndex = NSNotFound;
    UIColor *sliceColor;
    geneIndex = index;
    if (identifier)
    {
        if ([identifier isEqualToString:@"GENE"]) {
            gene = _geneList[index];
            if ([_smallChartPatientMutationIndex containsObject:[NSNumber numberWithInteger:index]]){
                sliceColor = [geneDataHelper geneColorWithIndex:geneIndex];
        
            }else{
                sliceColor = [geneDataHelper geneShallowColorWithIndex:geneIndex];
            }
        
        } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
            gene = _bigOuterGeneList[index];
            if ([_bigOuterGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:index]]){
                sliceColor = [geneDataHelper geneColorWithIndex:geneIndex];
            }else{
                sliceColor = [geneDataHelper geneShallowColorWithIndex:geneIndex];
            }
        } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
            gene = _bigInnerGeneList[index];
            if ([_bigInnerGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:index]]){
                sliceColor = [geneDataHelper geneColorWithIndex:geneIndex];
            }else{
                sliceColor = [geneDataHelper geneShallowColorWithIndex:geneIndex];
            }
        }
    }

    
    if (sliceColor) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[sliceColor CGColor]]];
    } else {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f] CGColor]]];
    }
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    NSString *gene, *geneDisplayName,  *labelText;
    UIColor *labelColor;
    NSNumber *count;
    CPTTextLayer *textLayer;
    CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
    BOOL isPatients = NO;
    
    id identifier = plot.identifier;
    
    if (identifier) {
        if ([identifier isEqualToString:@"GENE"]) {
            gene = _geneList[idx];
       /*     count = _chartGeneData[gene];
            if ([count intValue] < 1) {
                return nil;
            } else {
                count = nil;
            }*/
            
            isPatients = [_smallGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
        } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
            gene = _bigOuterGeneList[idx];
            count = _bigOuterChartGeneData[gene];
            labelColor = [geneDataHelper geneLabelColorWithName:gene];
            isPatients = [_bigOuterGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
        } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
            gene = _bigInnerGeneList[idx];
            count = _bigInnerChartGeneData[gene];
            labelColor = [geneDataHelper geneLabelColorWithName:gene];
            isPatients = [_bigInnerGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
        }
    }
    
     if (gene) {
         geneDisplayName = gene;
         
         if (count) {
             labelText = [NSString stringWithFormat:@"%@\n(%i pts.)", geneDisplayName, [count intValue]];
         } else {
             labelText = geneDisplayName;
         }
     }
    
    if (identifier){
        if ([identifier isEqualToString:@"GENE"]|[identifier isEqualToString:@"BIGGENEOUTER"]){
            textStyle.fontSize = 7.0f;
        }else if ([identifier isEqualToString:@"BIGGENEINNER"]){
            textStyle.fontSize = 0.0f;
        }
    }
    //textStyle.fontSize = 7.0f;
    
    if (labelText) {
        if (labelColor) {
            textStyle.color = [CPTColor colorWithCGColor:[labelColor CGColor]];
        }
        
        if (isPatients) {
            textStyle.fontSize = 8.0f;
            
        
        }
        
        textLayer = [[CPTTextLayer alloc] initWithText:labelText
                                                 style:textStyle];

        [textLayer sizeToFit];
        return textLayer;
    } else {
        textLayer = [[CPTTextLayer alloc] initWithText:labelText
                                                 style:textStyle];
        [textLayer sizeToFit];
        return textLayer;
    }
}

- (CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    id identifier = pieChart.identifier;
    BOOL isPatients = NO;

    if (identifier) {
        
        if ([identifier isEqualToString:@"GENE"]) {
            return ([_smallChartPatientMutationIndex containsObject:[NSNumber numberWithInteger:idx]]) ? geneChartHighlightOffset : 0.0f;
        }
        
        /*if ([identifier isEqualToString:@"MUTATION"]) {
            return ((long)idx == _smallChartPatientMutationIndex) ? mutationChartHighlightOffset : 0.0f;
        }*/
        
        if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
            isPatients = [_bigOuterGeneList count] > 1 && [_bigOuterGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
        } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
            isPatients = [_bigInnerGeneList count] > 1 && [_bigInnerGeneChartWithMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
     /*   } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
            isPatients = [_bigOuterMutationList count] > 1 && [_bigOuterChartPatientMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
        } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
            isPatients = [_bigInnerMutationList count] > 1 && [_bigInnerChartPatientMutationIndex containsObject:[NSNumber numberWithInteger:idx]];
     */   }
    }

    if (isPatients) {
        return 20.0f;
    } else {
        return 0.0f;
    }
}


#pragma mark - CPTPieChartDelegate implementation

- (void)handleTouchActionInChart:(CPTPlot *)plot atSliceIndex:(NSUInteger)idx
{
    id identifier = plot.identifier;
    
    NSString *gene, *title;
    //NSString *dnaSequenceVariation, *alleleName;
    NSURL *url;
    //NSNumber *alleleNameCount;
    
    // Big chart loading
    if ([identifier isEqualToString:@"GENE"]) {
        [largePiePlotNavController renderBigGenePieChartWithIdentifier:@"GENE"
                                                         andDataSource:self
                                                           andDelegate:self
                                                              andTitle:[NSString stringWithFormat:@"Mutated Genes Observed in %@", _disease]];
        
        [self presentViewController:largePiePlotNavController animated:YES completion:nil];
  /*  } else if ([identifier isEqualToString:@"MUTATION"]) {
        [largePiePlotNavController renderBigGenePieChartWithIdentifier:@"MUTATION"
                                                         andDataSource:self
                                                           andDelegate:self
                                                              andTitle:[NSString stringWithFormat:@"Observed Variants in %@ Pts. with %@ Mutation", _disease, _geneWithMutation]];
        
        [self presentViewController:largePiePlotNavController animated:YES completion:nil];
    
    // Link loading
  */  } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
        gene = _bigOuterGeneList[idx];
    } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
        gene = _bigInnerGeneList[idx];
  /*  } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
        dnaSequenceVariation = _bigOuterMutationList[idx];
    } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
        dnaSequenceVariation = _bigInnerMutationList[idx];
   */ }
    
    if (gene) {
        title = [NSString stringWithFormat:@"%@ Reference", gene];
        url = [geneDataHelper getReferenceURLForGene:gene];
   /* } else if (dnaSequenceVariation) {
        alleleName = [_mutationMap objectForKey:dnaSequenceVariation];
        alleleNameCount = [_alleleNameCount objectForKey:alleleName];
        if ([alleleNameCount intValue] > 1) {
            title = [NSString stringWithFormat:@"%@ (%@) Reference", alleleName, dnaSequenceVariation];
        } else {
            title = [NSString stringWithFormat:@"%@ Reference", alleleName];
        }
        url = [mutationDataHelper getReferenceURLForSequenceVariation:dnaSequenceVariation inGene:_geneWithMutation];
    */}
    
    if (url) {
        
        [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        
        _webViewController.title = title;
        _currentURLString = [url absoluteString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        [largePiePlotNavController pushViewController:_webViewController animated:YES];
    }
}

- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx
{
    [self handleTouchActionInChart:plot atSliceIndex:idx];
}

- (void)plot:(CPTPlot *)plot dataLabelTouchDownAtRecordIndex:(NSUInteger)idx
{
    [self handleTouchActionInChart:plot atSliceIndex:idx];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *newURLString = [request.URL absoluteString];
    if ([newURLString isEqualToString:_currentURLString]) {
        return YES;
    }
    
    [[UIApplication sharedApplication] openURL:request.URL];
    
    return NO;
}

- (void)closeLargeChart:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}





@end
