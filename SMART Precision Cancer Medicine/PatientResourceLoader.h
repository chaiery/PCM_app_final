//
//  LoadPatientResources.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatientResourceLoaderDelegate.h"

@interface PatientResourceLoader : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, assign) id<PatientResourceLoaderDelegate> delegate;

- (void) queryFhirServerForPatientResourceXmlFileList;
- (void) populateCoreDataWithRemotePatientResourceXmlFiles;

- (void) locateLocalPatientResourceXmlFiles;
- (void) populateCoreDataFromLocalPatientResourceXmlFiles;

@end
