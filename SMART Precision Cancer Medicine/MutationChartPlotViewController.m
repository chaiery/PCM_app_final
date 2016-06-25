//
//  MutationChartPlotViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/23.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

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

@interface MutationChartPlotViewController ()<UIWebViewDelegate, CPTPieChartDelegate, CPTPieChartDataSource, CPTLegendDelegate, CPTPlotSpaceDelegate>
@property (nonatomic, strong) NSString *disease;
@property (nonatomic, weak) Observation *mutationObservation;
@property (nonatomic, strong) NSString *geneWithMutation;
@property (nonatomic, strong) NSString *mutationDNASequenceVariation;
@property (nonatomic, strong) NSString *mutationAlleleName;
@property (nonatomic, strong) NSDictionary *mutationMap;
@property (nonatomic, strong) NSMutableDictionary *alleleNameCount;

@property (nonatomic, strong) NSMutableDictionary *chartGeneData;
@property (nonatomic, strong) NSMutableDictionary *bigOuterChartGeneData;
@property (nonatomic, strong) NSMutableDictionary *bigInnerChartGeneData;
@property (nonatomic, strong) NSMutableArray *geneList;
@property (nonatomic, strong) NSMutableArray *bigOuterGeneList;
@property (nonatomic, strong) NSMutableArray *bigInnerGeneList;
@property (nonatomic) int largestGene;

@property (nonatomic, strong) NSMutableDictionary *chartMutationData;
@property (nonatomic, strong) NSMutableDictionary *bigOuterChartMutationData;
@property (nonatomic, strong) NSMutableDictionary *bigInnerChartMutationData;
@property (nonatomic, strong) NSMutableArray *mutationList;
@property (nonatomic, strong) NSMutableArray *bigOuterMutationList;
@property (nonatomic, strong) NSMutableArray *bigInnerMutationList;
@property (nonatomic) int largestMutation;

@property (nonatomic, strong) PCMSmallPieChart *smallGeneChart;
@property (nonatomic, strong) PCMMediumPieChart *mediumGeneChart;
@property (nonatomic, strong) PCMSmallPieChart *smallMutationChart;
@property (nonatomic, strong) PCMMediumPieChart *mediumMutationChart;

//@property (nonatomic, strong) PCMXYGraph *geneGraph;
//@property (nonatomic, weak) CPTPieChart *currentGeneChart;
@property (nonatomic, strong) PCMXYGraph *mutationGraph;
@property (nonatomic, weak) CPTPieChart *currentMutationChart;

@property (nonatomic, strong) UIView *rootView;

//@property (nonatomic, strong) PCMGraphHostingView *genePlotHostingView;
@property (nonatomic, strong) PCMGraphHostingView *mutationPlotHostingView;

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

@implementation MutationChartPlotViewController

@synthesize geneChartHighlightOffset;
@synthesize mutationChartHighlightOffset;


- (instancetype) initWithObservation:(Observation *)mutationObservation withDiseases:(NSString *)disease{
    self = [super init];
    _mutationObservation = mutationObservation;
    _disease = disease;
    if (self) {
        
        _plotsInitialized = NO;
        
        RICAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _entitySearchService = appDelegate.entitySearchService;
        
        
        if (!mutationDataHelper) {
            mutationDataHelper = [[MutationDataHelper alloc] init];
        }
        
        if (!largePiePlotNavController) {
            largePiePlotNavController = [[LargePiePlotNavigationController alloc] init];
        }

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

        mutationChartHighlightOffset = 0;
        [self initializeGraphData];
    }
    return self;
}

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
        if ([_mutationList count] > 0) {
             [self createPopulationMutationGraph];
             }
            _plotsInitialized = YES;
             [self highlightSlice];
        } else {
            
        }
        [SVProgressHUD dismiss];
}

- (void)viewWillLayoutSubviews
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (_mutationPlotHostingView) {
            
            if (_currentMutationChart) {
                [_mutationGraph removePlot:_currentMutationChart];
            }
            _currentMutationChart = _smallMutationChart;
            [_mutationGraph addPlot:_currentMutationChart];
            
            [_rootView.superview removeConstraints:_bothChartLandscapeConstraints];
            [_rootView.superview addConstraints:_bothChartPortraitConstraints];
            
        }
    } else {
        if ( _mutationPlotHostingView) {
            
            if (_currentMutationChart) {
                [_mutationGraph removePlot:_currentMutationChart];
            }
            _currentMutationChart = _smallMutationChart;
            
            [_rootView.superview removeConstraints:_bothChartPortraitConstraints];
            [_rootView.superview addConstraints:_bothChartLandscapeConstraints];
            
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
        
        if (_mutationGraph) {
            [CPTAnimation animate:self
                         property:@"mutationChartHighlightOffset"
                             from:0.0
                               to:20.0
                         duration:0.75
                   animationCurve:CPTAnimationCurveCubicOut
                         delegate:nil];
        }
    });
}


- (void)setMutationChartHighlightOffset:(CGFloat)newOffset
{
    if (newOffset != mutationChartHighlightOffset) {
        mutationChartHighlightOffset = newOffset;
        
        [_mutationGraph reloadData];
    }
}

- (void)initializeGraphData
{

    __block NSNumber *itemCount;
    //__block BOOL errorEncountered = NO;
    __block int itemCountInt;
    __block int minMutationSize = 10;

        
    _chartGeneData = [[NSMutableDictionary alloc] init];
    _bigOuterChartGeneData = [[NSMutableDictionary alloc] init];
    _bigInnerChartGeneData = [[NSMutableDictionary alloc] init];
    _geneWithMutation = [_mutationObservation geneIdDisplay];

    if (_mutationObservation) {
        
        _mutationDNASequenceVariation = [_mutationObservation dnaSequenceVariation];
        _mutationAlleleName = [_mutationObservation alleleName];
        
        _mutationMap = [_entitySearchService getAllMutationsForGene:_geneWithMutation inDisease:_disease];
        if (nil == _mutationMap || [_mutationMap count] == 0) {
            
            [SVProgressHUD showErrorWithStatus:@"Unable to get list of mutations from CoreData, please give device to developer for begugging"];
            
        } else {
            
            _mutationList = [[NSMutableArray alloc ] init];
            _bigOuterMutationList = [[NSMutableArray alloc] init];
            _bigInnerMutationList = [[NSMutableArray alloc] init];
            
            _chartMutationData = [[NSMutableDictionary alloc] init];
            _bigOuterChartMutationData = [[NSMutableDictionary alloc] init];
            _bigInnerChartMutationData = [[NSMutableDictionary alloc] init];
            
            _alleleNameCount = [[NSMutableDictionary alloc] init];
            
            __block long alleleNameCount;
            
            [_mutationMap enumerateKeysAndObjectsUsingBlock:^(id variant, id alleleName, BOOL *stop) {
                
                itemCount = [_entitySearchService countPatientsWithDNASequenceVariation:variant inGene:_geneWithMutation inDisease:_disease];
                if ((itemCountInt = [itemCount intValue]) > 0) {
                    
                    [_chartMutationData setObject:itemCount forKey:variant];
                    [_mutationList addObject:variant];
                    
                    if (itemCountInt > _largestMutation) {
                        _largestMutation = itemCountInt;
                    }
                    
                    if (itemCountInt > minMutationSize) {
                        [_bigOuterChartMutationData setObject:itemCount forKey:variant];
                        [_bigOuterMutationList addObject:variant];
                    } else {
                        [_bigInnerChartMutationData setObject:itemCount forKey:variant];
                        [_bigInnerMutationList addObject:variant];
                    }
                    
                    alleleNameCount = [[_alleleNameCount objectForKey:alleleName] intValue];
                    if (alleleNameCount == NSNotFound) {
                        alleleNameCount = 0;
                    }
                    
                    alleleNameCount++;
                    [_alleleNameCount setObject:[NSNumber numberWithLong:alleleNameCount] forKey:alleleName];
                    
                }
            }];
            
            _smallChartPatientMutationIndex = [_mutationList indexOfObject:_mutationDNASequenceVariation];
            _bigOuterChartPatientMutationIndex = [_bigOuterMutationList indexOfObject:_mutationDNASequenceVariation];
            _bigInnerChartPatientMutationIndex = [_bigInnerMutationList indexOfObject:_mutationDNASequenceVariation];
        }
    }
}



- (void) createPopulationMutationGraph
{
    _mutationPlotHostingView = [[PCMGraphHostingView alloc] init];
    [_rootView addSubview:_mutationPlotHostingView];
    
    _mutationGraph = [[PCMXYGraph alloc] init];
    _mutationGraph.title = [NSString stringWithFormat:@"Observed Variants in %@ Patients\nwith %@ Mutation", _disease, _geneWithMutation];
    [_mutationPlotHostingView setHostedGraph:_mutationGraph];
    
    _smallMutationChart = [[PCMSmallPieChart alloc] init];
    _mediumMutationChart = [[PCMMediumPieChart alloc] init];
    
    _smallMutationChart.identifier = @"MUTATION";
    _smallMutationChart.delegate = self;
    _smallMutationChart.dataSource = self;
    _mediumMutationChart.identifier = @"MUTATION";
    _mediumMutationChart.delegate = self;
    _mediumMutationChart.dataSource = self;
    
    _bothChartPortraitConstraints = [[NSMutableArray alloc] init];
    [_bothChartPortraitConstraints addObject:
     [NSLayoutConstraint constraintWithItem:_rootView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:375.0f]];
    [_bothChartPortraitConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mutationPlotHostingView]|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_mutationPlotHostingView)]];
    [_bothChartPortraitConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mutationPlotHostingView]|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_mutationPlotHostingView)]];
    
    
    _bothChartLandscapeConstraints = [[NSMutableArray alloc] init];
    [_bothChartLandscapeConstraints addObject:
     [NSLayoutConstraint constraintWithItem:_rootView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:500.0f]];
    [_bothChartLandscapeConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mutationPlotHostingView]|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_mutationPlotHostingView)]];
    [_bothChartPortraitConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mutationPlotHostingView]|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_mutationPlotHostingView)]];
}
#pragma mark - CPTPieChartDataSource implementation

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    id identifier = plot.identifier;
    int count = 0;
    
    if (identifier)
    {
        if ([identifier isEqualToString:@"MUTATION"]) {
             count = (int)[_chartMutationData count];
             } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
             count = (int)[_bigOuterChartMutationData count];
             } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
             count = (int)[_bigInnerChartMutationData count];
             }
    }
    
    return count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id identifier = plot.identifier;
    
    NSNumber *number;
    
    if (identifier) {
        if ([identifier isEqualToString:@"MUTATION"]) {
             number = _chartMutationData[_mutationList[index]];
             } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
             number = _bigOuterChartMutationData[_bigOuterMutationList[index]];
             } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
             number = _bigInnerChartMutationData[_bigInnerMutationList[index]];
             }
    }
    
    return number;
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    id identifier = pieChart.identifier;
    
    NSString *gene, *mutation;
    NSUInteger mutationIndex = NSNotFound;
    UIColor *sliceColor;
    
    if (identifier)
    {
        if ([identifier isEqualToString:@"MUTATION"]) {
             mutation = _mutationList[index];
             mutationIndex = index;
             } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
             mutation = _bigOuterMutationList[index];
             mutationIndex = [_mutationList indexOfObject:mutation];
             } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
             mutation = _bigInnerMutationList[index];
             mutationIndex = [_mutationList indexOfObject:mutation];
             }
    }
    
    if (gene) {
        sliceColor = [geneDataHelper geneColorWithName:gene];
    } else if (mutation) {
        sliceColor = [mutationDataHelper mutationColorWithIndex:mutationIndex];
    }
    
    if (sliceColor) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[sliceColor CGColor]]];
    } else {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f] CGColor]]];
    }
}


- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    NSString *labelText;
    NSString *mutationDisplayName, *dnaSequenceVariation, *alleleName;
    UIColor *labelColor;
    NSNumber *count;
    NSNumber *alleleNameCount;
    CPTTextLayer *textLayer;
    CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
    BOOL isPatients = NO;
    
    id identifier = plot.identifier;
    
    if (identifier) {
        if ([identifier isEqualToString:@"MUTATION"]) {
             dnaSequenceVariation = _mutationList[idx];
             count = _chartMutationData[dnaSequenceVariation];
             if ([count intValue] < 1) {
             return nil;
             } else {
             count = nil;
             }
             isPatients = ((long)idx == _smallChartPatientMutationIndex);
             } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
             dnaSequenceVariation = _bigOuterMutationList[idx];
             count = _bigOuterChartMutationData[dnaSequenceVariation];
             labelColor = [mutationDataHelper mutationLabelColorWithIndex:idx];
             isPatients = ((long)idx == _bigOuterChartPatientMutationIndex);
             } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
             dnaSequenceVariation = _bigInnerMutationList[idx];
             count = _bigInnerChartMutationData[dnaSequenceVariation];
             labelColor = [mutationDataHelper mutationLabelColorWithIndex:idx];
             isPatients = ((long)idx == _bigInnerChartPatientMutationIndex);
        }
    }

    if (dnaSequenceVariation) {
            alleleName = [_mutationMap objectForKey:dnaSequenceVariation];
            alleleNameCount = [_alleleNameCount objectForKey:alleleName];
         
            if (alleleNameCount && [alleleNameCount longValue] >= 1) {
                mutationDisplayName = [NSString stringWithFormat:@"%@ (%@)", alleleName, dnaSequenceVariation];
            } else {
                mutationDisplayName = alleleName;
            }
         
            if (count) {
                labelText = [NSString stringWithFormat:@"%@\n(%i pts.)", mutationDisplayName, [count intValue]];
            } else {
                labelText = mutationDisplayName;
            }
        }
    
    
    textStyle.fontSize = 5.0f;
    
        if (labelText) {
            if (labelColor) {
                textStyle.color = [CPTColor colorWithCGColor:[labelColor CGColor]];
            }
            
            if (isPatients) {
                textStyle.fontSize = 10.0f;
                
                
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
     
     /*if ([identifier isEqualToString:@"GENE"]) {
     return ((long)idx == _smallChartPatientMutationIndex) ? geneChartHighlightOffset : 0.0f;
     }*/
     
     if ([identifier isEqualToString:@"MUTATION"]) {
     return ((long)idx == _smallChartPatientMutationIndex) ? mutationChartHighlightOffset : 0.0f;
    /* }
     
     if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
     isPatients = [_bigOuterGeneList count] > 1 && (long)idx == _bigOuterGeneChartWithMutationIndex;
     } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
     isPatients = [_bigInnerGeneList count] > 1 && (long)idx == _bigInnerGeneChartWithMutationIndex;*/
     } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
     isPatients = [_bigOuterMutationList count] > 1 && (long)idx == _bigOuterChartPatientMutationIndex;
     } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
     isPatients = [_bigInnerMutationList count] > 1 && (long)idx == _bigInnerChartPatientMutationIndex;
     }
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
    NSString *dnaSequenceVariation, *alleleName;
    NSURL *url;
    NSNumber *alleleNameCount;
    
    // Big chart loading
    if ([identifier isEqualToString:@"GENE"]) {
        [largePiePlotNavController renderBigGenePieChartWithIdentifier:@"GENE"
                                                         andDataSource:self
                                                           andDelegate:self
                                                              andTitle:[NSString stringWithFormat:@"Mutated Genes Observed in %@", _disease]];
        
        [self presentViewController:largePiePlotNavController animated:YES completion:nil];
         } else if ([identifier isEqualToString:@"MUTATION"]) {
         [largePiePlotNavController renderBigGenePieChartWithIdentifier:@"MUTATION"
         andDataSource:self
         andDelegate:self
         andTitle:[NSString stringWithFormat:@"Observed Variants in %@ Pts. with %@ Mutation", _disease, _geneWithMutation]];
         
         [self presentViewController:largePiePlotNavController animated:YES completion:nil];
         
         // Link loading
           } else if ([identifier isEqualToString:@"BIGGENEOUTER"]) {
             gene = _bigOuterGeneList[idx];
         } else if ([identifier isEqualToString:@"BIGGENEINNER"]) {
             gene = _bigInnerGeneList[idx];
               } else if ([identifier isEqualToString:@"BIGMUTATIONOUTER"]) {
              dnaSequenceVariation = _bigOuterMutationList[idx];
              } else if ([identifier isEqualToString:@"BIGMUTATIONINNER"]) {
              dnaSequenceVariation = _bigInnerMutationList[idx];
            }
    
    if (gene) {
        title = [NSString stringWithFormat:@"%@ Reference", gene];
        url = [geneDataHelper getReferenceURLForGene:gene];
         } else if (dnaSequenceVariation) {
         alleleName = [_mutationMap objectForKey:dnaSequenceVariation];
         alleleNameCount = [_alleleNameCount objectForKey:alleleName];
         if ([alleleNameCount intValue] > 1) {
         title = [NSString stringWithFormat:@"%@ (%@) Reference", alleleName, dnaSequenceVariation];
         } else {
         title = [NSString stringWithFormat:@"%@ Reference", alleleName];
         }
         url = [mutationDataHelper getReferenceURLForSequenceVariation:dnaSequenceVariation inGene:_geneWithMutation];
         }
    
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

