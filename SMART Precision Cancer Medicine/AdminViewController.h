//
//  AdminViewController.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/27/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntitySearchService.h"
#import "PatientResourceLoader.h"
#import "PatientResourceLoaderDelegate.h"

@interface AdminViewController : UIViewController <PatientResourceLoaderDelegate>

@property (nonatomic, weak) PatientResourceLoader *patientResourceLoader;
@property (nonatomic, weak) EntitySearchService *entitySearchService;

@end
