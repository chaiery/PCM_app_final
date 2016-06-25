//
//  Observation.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiagnosticReport, Patient;

@interface Observation : NSManagedObject

@property (nonatomic, retain) NSString * xmlId;
@property (nonatomic, retain) NSString * referenceAllele;
@property (nonatomic, retain) NSString * observedAllele;
@property (nonatomic, retain) NSString * alleleName;
@property (nonatomic, retain) NSString * assessedCondition;
@property (nonatomic, retain) NSString * dnaSequenceVariation;
@property (nonatomic, retain) NSString * geneIdCode;
@property (nonatomic, retain) NSString * geneIdDisplay;
@property (nonatomic, retain) Patient *subject;
@property (nonatomic, retain) DiagnosticReport *diagnosticReport;

+ (instancetype) insertNewObjectIntoContext:(NSManagedObjectContext *)context;
- (NSComparisonResult)compareObservation:(Observation *)_observation;

@end
