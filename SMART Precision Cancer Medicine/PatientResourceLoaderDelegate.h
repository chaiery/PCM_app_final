//
//  PatientResourceLoaderDelegate.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SMART_Precision_Cancer_Medicine_PatientResourceLoaderDelegate_h
#define SMART_Precision_Cancer_Medicine_PatientResourceLoaderDelegate_h

@protocol PatientResourceLoaderDelegate <NSObject>

- (void) queryingForRemotePatientResourceFileList;
- (void) receivedRemotePatientResourceFileList:(NSArray *)filenames andCount:(NSNumber *)fileCount;
- (void) importingRemotePatientResouce:(NSString *)filename atIndex:(long)index ofTotal:(long)total;
- (void) finishedImportingRemotePatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total;

- (void) locatingLocalPatientResourceXmlFiles;
- (void) locatedLocalPatientResourceXmlFiles:(NSArray *)fileNames andCount:(NSNumber *)fileCount;
- (void) importingLocalPatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total;
- (void) finishedImportingLocalPatientResource:(NSString *)filename atIndex:(long)index ofTotal:(long)total;

- (void) finishedImportingPatientResources;

- (void) resourceLoaderErrorRaised:(NSString *)message;

@end

#endif
