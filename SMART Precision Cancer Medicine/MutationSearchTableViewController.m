//
//  MutationSearchTableViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import "MutationSearchTableViewController.h"
#import "SVProgressHUD.h"
#import "Observation.h"
#import "ObservationViewController.h"
//@interface MutationSearchTableViewController () <UISearchResultsUpdating, UISearchBarDelegate, UISearchResultsUpdating>
@interface MutationSearchTableViewController ()
@property (nonatomic, weak) NSArray *mutationObservations;
@property (nonatomic, strong) NSString *disease;
@property (nonatomic, strong) Patient *patient;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation MutationSearchTableViewController

- (id) initWithObservation:(NSArray *)mutationObservations withDiseases:(NSString *)disease
{
    self = [super init];
    if (self) {
        _disease = disease;
        _mutationObservations = mutationObservations;
        self.title = @"Mutations";
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
        self.definesPresentationContext = YES;
        self.navigationController.definesPresentationContext = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.searchResultsUpdater = self;
    
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;*/
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _searchResults = _mutationObservations;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSString *rowText = [NSString stringWithFormat:@"%@, variant:%@", [mutationObservation geneIdDisplay],[mutationObservation dnaSequenceVariation]];
    
    cell.textLabel.text = [rowText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    ObservationViewController *pvc = [[ObservationViewController alloc] initWithObservation:_mutationObservations[indexPath.row]
                                                                            andWithDiseases:_disease];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - UISearchResultsUpdating implementation

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    _searchResults = _mutationObservations;
    
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate implementation

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:_searchController];
}

@end
