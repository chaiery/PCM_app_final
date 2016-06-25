//
//  MutationGeneTable.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/29.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "MutationGeneTableView.h"
#import "Observation.h"
#import "MutationChartPlotViewController.h"

@interface MutationGeneTableView()

@property (nonatomic, weak) NSArray *mutationObservations;
@property (nonatomic, strong) NSString *disease;

@end

@implementation MutationGeneTableView


#pragma mark - Table data methods
- (instancetype)initWithDisease:(NSString *)disease andMutationObservation:(NSArray *)mutationObservations
{
    self = [super init];
    if (self) {
        _disease = disease;
        _mutationObservations = mutationObservations;
        
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == _mutationObservations) {
        return 0;
    }
    
    return [_mutationObservations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    long row = indexPath.row;
    Observation *mutationObservation = _mutationObservations[row];
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil )
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSString *rowText = [NSString stringWithFormat:@"%@", [mutationObservation geneIdDisplay]];
    
    cell.textLabel.text = [rowText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutationChartPlotViewController *pvc = [[MutationChartPlotViewController alloc] initWithObservation:_mutationObservations[indexPath.row]
                                                                                           withDiseases:_disease];
    
    [self pushViewController:pvc animated:YES];
}

*/

@end
