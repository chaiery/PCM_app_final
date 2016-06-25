//
//  SplashScreenViewController.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SplashScreenView.h"
#import "PatientResourceLoader.h"
#import "SVProgressHUD.h"
#import "PatientResourceLoaderDelegate.h"
#import "EntitySearchService.h"

@interface SplashScreenViewController : UIViewController <PatientResourceLoaderDelegate>

@property (nonatomic, weak) PatientResourceLoader *patientResourceLoader;
@property (nonatomic, weak) EntitySearchService *entitySearchService;

@end
