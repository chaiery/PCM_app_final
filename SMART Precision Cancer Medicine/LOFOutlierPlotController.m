//
//  LOFOutlierPlotController.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/8/6.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "LOFOutlierPlotController.h"
#import "RICAppDelegate.h"
#import "SVProgressHUD.h"
#import "math.h"
#import "CorePlot-CocoaTouch.h"


@interface LOFOutlierPlotController ()
@property (nonatomic, weak) EntitySearchService *entitySearchService;
@property (nonatomic, strong) NSString *disease;
@property (nonatomic, weak) NSArray *mutationObservations;
@property (nonatomic, strong) NSMutableArray *geneList;
@property (nonatomic, strong) NSMutableDictionary *chartGeneData;
@property (nonatomic, strong) NSMutableArray *geneWithMutations;
@property (nonatomic, strong) NSMutableArray *mutationMaps;
@property (nonatomic, strong) Patient *patient;
@property (nonatomic, strong) NSArray *featureMatrix;
@property (nonatomic, strong) NSArray *lof;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSNumber *maxy;
@property (nonatomic, strong) NSNumber *internal;
@property (nonatomic) NSUInteger index;
@end

@implementation LOFOutlierPlotController

- (instancetype)initWithPatient:(Patient *)patient
                     andDisease:(NSString *)disease
         andMutationObservation:(NSArray *)mutationObservations
{
    self = [super init];
    if (self) {
        RICAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _entitySearchService = appDelegate.entitySearchService;
        _patient = patient;
        _disease = disease;
        _mutationObservations = mutationObservations;
        [self initializeData];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    CGRect frame = CGRectMake(100,300, 500,300);
    

    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    hostView.allowPinchScaling = YES;
    
    [self.view addSubview:hostView];
    hostView.backgroundColor = [UIColor whiteColor];
    
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
    graph.plotAreaFrame.masksToBorder = NO;
    hostView.hostedGraph = graph;
    
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    [graph addPlot:scatterPlot];
    scatterPlot.dataSource = self;
    

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) scatterPlot.plotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat([_maxy floatValue])];
    
    graph.plotAreaFrame . borderLineStyle = nil ;
    graph.plotAreaFrame . cornerRadius = 0.0f ;
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 30.0f;
    graph.paddingTop    = -1.0f;
    graph.paddingRight  = -5.0f;

    graph.plotAreaFrame . paddingLeft = 70.0 ;
    graph.plotAreaFrame . paddingTop = 20.0 ;
    graph.plotAreaFrame . paddingRight = 20.0 ;
    graph.plotAreaFrame . paddingBottom = 80.0 ;
    
    graph . title = [NSString stringWithFormat:@"The distribution of LOFs for patients with breast cancer\n\t\t(LOF for this patient is %@)",_lof[_index]];
    

    CPTMutableTextStyle * textStyle=[ CPTMutableTextStyle textStyle ];

    textStyle.color = [ CPTColor blackColor ];
    textStyle.fontSize = 16.0f ;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake ( 25.0f ,  50.0f );

    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet;

    axisSet.xAxis.title = @"LOF";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;

    axisSet.yAxis.title = @"Percentage";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    
    CPTMutableLineStyle * lineStyle=[[ CPTMutableLineStyle alloc ] init ];
    lineStyle.lineColor=[CPTColor blackColor];
    lineStyle.miterLimit=1.0f;
    lineStyle. lineWidth = 1.0f ;
    CPTMutableLineStyle * lineStyleForTick=[[ CPTMutableLineStyle alloc ] init ];
    lineStyleForTick.lineColor=[CPTColor blackColor];
    lineStyleForTick.miterLimit=1.0f;
    lineStyleForTick. lineWidth = 1.0f ;

    axisSet.xAxis. axisLineStyle = lineStyle;
    axisSet.xAxis. majorTickLineStyle = lineStyleForTick;
    axisSet.xAxis. majorTickLength = 5;
    axisSet.xAxis. minorTickLineStyle =nil;
    axisSet.xAxis. minorTickLength = 1 ;
    axisSet.xAxis. majorIntervalLength = CPTDecimalFromString ( @"0.5" );
    
    axisSet.yAxis. axisLineStyle = lineStyle;
    axisSet.yAxis. majorTickLineStyle = lineStyleForTick;
    axisSet.yAxis. majorTickLength = 5;
    axisSet.yAxis. minorTickLineStyle =nil;
    axisSet.yAxis. minorTickLength = 1 ;
    axisSet.yAxis. majorIntervalLength = CPTDecimalFromString ( @"0.1" );
    

    axisSet.xAxis. titleOffset = 25.0f ;
    axisSet.yAxis. titleOffset = 45.0f ;
    
     CPTBarPlot *barPlot = [ CPTBarPlot tubularBarPlotWithColor :[ CPTColor blueColor ] horizontalBars : NO ];
    barPlot.barWidth = CPTDecimalFromString ( @"0.03" );
    barPlot. baseValue = CPTDecimalFromString ( @"0" );
    

    barPlot. dataSource = self ;

    barPlot. identifier = @"Bar Plot 1" ;

    [ graph addPlot :barPlot toPlotSpace :plotSpace];

}

- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_dataArray count];
}


- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if(fieldEnum == CPTScatterPlotFieldY){
        return [_dataArray objectAtIndex:index];
    }else{
        float xvalue;
        xvalue = [_internal floatValue] * index;
        return [NSNumber numberWithFloat:xvalue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializeData{
    NSArray *geneList = [_entitySearchService getAllGenesForDisease:_disease];
    geneList = [geneList sortedArrayUsingSelector:@selector(compare:)];
    if (nil == geneList || [geneList count] == 0) {
        [SVProgressHUD showErrorWithStatus:@"Unable to get list of genes from CoreData, please give device to developer for debugging."];
    } else {
    
        NSArray *patientList = [_entitySearchService searchForPatientsByDisease:_disease];
        _index = [patientList indexOfObject:_patient];
        NSMutableArray *featureMatrix = [[NSMutableArray alloc] init];
        __block NSUInteger indexofMatrix;
        [patientList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqual:_patient]){
                indexofMatrix = idx;
            }
            NSMutableArray *featureVectorForEachPatient = [[NSMutableArray alloc] init];
            NSArray *mutationObservations = [[NSArray alloc] init];
            NSMutableArray *mutationGenes = [[NSMutableArray alloc] init];
            mutationObservations = [[obj observations] allObjects];
            [mutationObservations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [mutationGenes addObject:[obj geneIdDisplay]];
            }];
            [geneList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([mutationGenes containsObject:obj]){
                    [featureVectorForEachPatient addObject:[NSNumber numberWithInteger:1]];
                }else{
                    [featureVectorForEachPatient addObject:[NSNumber numberWithInteger:0]];
                }
                
            }];
            
            [featureMatrix addObject:featureVectorForEachPatient];
        
        }];
        
        _featureMatrix = featureMatrix;
        
        _lof = [self calculateLOF];
        _lof = [_lof sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSUInteger i,j;
        NSNumber *maxvalue = [_lof objectAtIndex:([_lof count]-1)];
        float internal = [maxvalue floatValue] / 50.0;
        _internal = [NSNumber numberWithFloat:internal];
        float temp = 0;
        for (i = 1; i<51; i++) {
            float countOfPoint = 0;
            for (j = 0; j < [_lof count]; j++){
                if (([_lof[j] floatValue] <= (i * internal)) && ([_lof[j] floatValue] > ((i-1) * internal))) {
                    countOfPoint++;
                }
            
            }
            [dataArray addObject:[NSNumber numberWithFloat:(countOfPoint/[_lof count])]];
            if (countOfPoint > temp){
                temp = countOfPoint;
            }
        }
        _dataArray = dataArray;
        _maxy = [NSNumber numberWithFloat: temp/[_lof count]*1.1];
    }
}

- (NSArray *)calculateLOF{
    NSUInteger setK = 50;
    NSUInteger numberOfPatients;
    numberOfPatients = [_featureMatrix count];
    NSUInteger i,j;
    //Calculate distance array--the distance between every pair of points.
    NSMutableArray *distanceMatrix = [[NSMutableArray alloc] init];
    for (i = 0;i < numberOfPatients;i++)
    {
        NSMutableArray *distanceForEachPatient = [[NSMutableArray alloc] init];
        for (j = 0;j < numberOfPatients;j++)
        {
            float distanceForOnePair = 0;
            NSInteger dim = [_featureMatrix[i] count];
            NSInteger k;
            for (k = 0;k < dim;k++)
            {
                distanceForOnePair += powf(([_featureMatrix[i][k] floatValue] - [_featureMatrix[j][k] floatValue]),2);
            }
            distanceForOnePair = sqrtf(distanceForOnePair);
            [distanceForEachPatient addObject:[NSNumber numberWithFloat:distanceForOnePair]];
        }
        
        NSArray *sortedDistanceForEachPatient = [distanceForEachPatient sortedArrayUsingSelector:@selector(compare:)];
        [distanceMatrix addObject:sortedDistanceForEachPatient];
        
    }
    
    //Core:the LOF value for each point.
    
    // k-distance
    NSMutableArray *lrd =[[NSMutableArray alloc] init];
    NSMutableArray *nlist =[[NSMutableArray alloc] init];
    for (i = 0;i < numberOfPatients; i++)
    {
        NSNumber *kdistance,*d,*reachdis,*sd;
        kdistance = distanceMatrix[i][setK];
        NSUInteger n = setK;
        
        
        while ([kdistance isEqual: distanceMatrix[i][n]]){
            n = n + 1;
        }
        [nlist addObject:[NSNumber numberWithInteger:n]];
        NSMutableArray *dForRow = [[NSMutableArray alloc] init];
        NSMutableArray *reachdisForRow = [[NSMutableArray alloc] init];
        
        for (j = 0;j < n;j++)
        {
            d = distanceMatrix[i][j];
            sd = distanceMatrix[j][setK];
            if ([d compare:sd]== NSOrderedAscending){
                reachdis = sd;
            }else{
                reachdis = d;
            }
            [dForRow addObject:d];
            [reachdisForRow addObject:reachdis];
        }
        
        
        float sum_reachdis = 0;
        for (j = 0; j < n; j++)
        {
            sum_reachdis += [reachdisForRow[j] floatValue];
        }
        // lrd for each point.
        [lrd addObject:[NSNumber numberWithFloat: ((float)n)/sum_reachdis]];
    }


    // LOF for each point.
    NSMutableArray *lof =[[NSMutableArray alloc] init];
    for (i = 0; i < numberOfPatients; i++) {
        float sumlrd = 0;
        for (j = 1;j < [nlist[i] integerValue]; j++) {
            sumlrd += [lrd[j] floatValue]/[lrd[i] floatValue];
        }
        [lof addObject:[NSNumber numberWithFloat:sumlrd/[nlist[i] floatValue]]];
    }
    
    return lof;
    
}




@end
