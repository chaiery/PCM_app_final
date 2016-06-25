//
//  AdminViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/27/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "AdminViewController.h"
#import "SVProgressHUD.h"

@interface AdminViewController ()

@property (nonatomic) BOOL processing;
@property (nonatomic, strong) UIButton *refreshRemoteDataButton;
@property (nonatomic, strong) UIButton *refreshLocalDataButton;

@end

@implementation AdminViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Admin";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Admin" image:nil selectedImage:nil];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _processing = NO;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    _refreshRemoteDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _refreshRemoteDataButton.translatesAutoresizingMaskIntoConstraints = NO;
    _refreshRemoteDataButton.layer.borderWidth = 3.0f;
    _refreshRemoteDataButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _refreshRemoteDataButton.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [_refreshRemoteDataButton setTitle:@"Refresh Patients From Remote Source" forState:UIControlStateNormal];
    [_refreshRemoteDataButton addTarget:self action:@selector(refreshPatientDataFromRemote:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshRemoteDataButton];
    
    _refreshLocalDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _refreshLocalDataButton.translatesAutoresizingMaskIntoConstraints = NO;
    _refreshLocalDataButton.layer.borderWidth = 3.0f;
    _refreshLocalDataButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _refreshLocalDataButton.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [_refreshLocalDataButton setTitle:@"Refresh Patients from Local Source" forState:UIControlStateNormal];
    [_refreshLocalDataButton addTarget:self action:@selector(refreshPatientDataFromLocal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshLocalDataButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[remote]-[local]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:@{@"remote": _refreshRemoteDataButton,
                                                                                @"local": _refreshLocalDataButton}]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_refreshRemoteDataButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_refreshRemoteDataButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshPatientDataFromRemote:(id)sender
{
    if (_processing) {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Please Wait"
                                                          message:@"Patient resources files are already being loaded, please wait until the previous request is completed before initiating another."
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
        [warning show];
    } else {
        _processing = YES;
        [_refreshRemoteDataButton setEnabled:NO];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        
        if ([_entitySearchService purgeCoreData]) {
            [SVProgressHUD showWithStatus:@"Purging CoreData..."];
            _patientResourceLoader.delegate = self;
            [_patientResourceLoader queryFhirServerForPatientResourceXmlFileList];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to purge schema, please give device to developer for debugging"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [SVProgressHUD dismiss];
            [alertView show];
        }
    }
}

- (void)refreshPatientDataFromLocal:(id)sender
{
    if (_processing) {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Please Wait"
                                                          message:@"Patient resources files are already being loaded, please wait until the previous request is completed before initiating another."
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
        [warning show];
    } else {
        _processing = YES;
        [_refreshRemoteDataButton setEnabled:NO];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        
        if ([_entitySearchService purgeCoreData]) {
            [SVProgressHUD showWithStatus:@"Purging CoreData..."];
            _patientResourceLoader.delegate = self;
            [_patientResourceLoader locateLocalPatientResourceXmlFiles];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to purge schema, please give device to developer for debugging"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [SVProgressHUD dismiss];
            [alertView show];
        }
    }
}

#pragma mark - PatientResourceLoaderDelegate implementation

- (void)queryingForRemotePatientResourceFileList
{
    [SVProgressHUD showWithStatus:@"Querying for Patient Resource Definitions"];
}

- (void)receivedRemotePatientResourceFileList:(NSArray *)filenames andCount:(NSNumber *)fileCount
{
    [SVProgressHUD showProgress:0.0f status:[NSString stringWithFormat:@"%d Patients found.", [fileCount intValue]]];
    [_patientResourceLoader populateCoreDataWithRemotePatientResourceXmlFiles];
}

- (void)importingRemotePatientResouce:(NSString *)filename atIndex:(long)index ofTotal:(long)total
{
    [SVProgressHUD showProgress:((float)index / (float)total) status:@"Importing patient data"];
}

- (void)finishedImportingRemotePatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total
{
    [_patientResourceLoader populateCoreDataWithRemotePatientResourceXmlFiles];
}

- (void) locatingLocalPatientResourceXmlFiles
{
    [SVProgressHUD showWithStatus:@"Locating local Patient Resource XML files"];
}

- (void) locatedLocalPatientResourceXmlFiles:(NSArray *)fileNames andCount:(NSNumber *)fileCount
{
    [SVProgressHUD showProgress:0.0f status:[NSString stringWithFormat:@"%d Patients found.", [fileCount intValue]]];
    [_patientResourceLoader populateCoreDataFromLocalPatientResourceXmlFiles];
}

- (void)importingLocalPatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total
{
    [SVProgressHUD showProgress:((float)index / (float)total) status:@"Importing patient data"];
}

- (void)finishedImportingLocalPatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total
{
    [_patientResourceLoader populateCoreDataFromLocalPatientResourceXmlFiles];
}

- (void)finishedImportingPatientResources
{
    [SVProgressHUD dismiss];
    _processing = NO;
    [_refreshRemoteDataButton setEnabled:YES];
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)resourceLoaderErrorRaised:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
