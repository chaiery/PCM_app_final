//
//  SplashScreenViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "RICAppDelegate.h"

@interface SplashScreenViewController  ()

@end

@implementation SplashScreenViewController

- (void)loadView
{
    self.view = [[SplashScreenView alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SVProgressHUD showWithStatus:@"Checking population data..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSUInteger count = [_entitySearchService countEntity:@"Patient"];
        
        if (count == NSNotFound || count == 0) {
            _patientResourceLoader.delegate = self;
            [_patientResourceLoader locateLocalPatientResourceXmlFiles];
        } else {
            [SVProgressHUD dismiss];
            RICAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.window setRootViewController:appDelegate.primaryTabBarController];
            [appDelegate.window makeKeyAndVisible];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    RICAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:appDelegate.primaryTabBarController];
    [appDelegate.window makeKeyAndVisible];
}

- (void)resourceLoaderErrorRaised:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}

@end
