//
//  ObservationViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "ObservationViewController.h"
#import "SVProgressHUD.h"
#import "MutationChartPlotViewController.h"
#import "Observation.h"
#import "ObservationContainerView.h"
#import "GeneDetailView.h"


@interface ObservationViewController ()

@property (nonatomic, weak) ObservationContainerView *containerView;
@property (nonatomic, strong) GeneDetailView *detailView;
//@property (nonatomic, strong) MutationGeneTableView *mutationGeneTableView;
//@property (nonatomic, strong) MutationGeneTableView *geneTableView;
@property (nonatomic, strong)  MutationChartPlotViewController *pvc;
@property (nonatomic, strong) UIButton *buttonForPatient;
@property (nonatomic, strong) Observation *observation;
@property (nonatomic, strong) NSString *diseaseName;
//@property (nonatomic, strong) Observation *mutationObservation;
@property (nonatomic,strong) NSArray *mutationObservations;

@end



@implementation ObservationViewController

- (instancetype)initWithObservation:(Observation *)observation andWithDiseases:(NSString *)disease
{
    self = [super init];
    if (self) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _observation = observation;
        self.title = [NSString stringWithFormat:@"%@", [_observation geneIdDisplay]];
        _diseaseName = disease;
    }
    return self;
}

- (void) loadView
{
    self.view = [[ObservationContainerView alloc] init];
    _containerView = (ObservationContainerView *)self.view;
    
    _detailView = [[GeneDetailView alloc] initWithGene:[_observation geneIdDisplay]];
    [_containerView setGeneDetailView:_detailView];
}


- (void)viewDidLoad
{
    [SVProgressHUD showWithStatus:@"Building Plots"];
    
    _pvc = [[MutationChartPlotViewController alloc] initWithObservation:(Observation *)_observation
                                                           withDiseases:(NSString *)_diseaseName];
    [self addChildViewController:_pvc];
    [_containerView setMutationPlotView:_pvc.view];
    
}

@end
