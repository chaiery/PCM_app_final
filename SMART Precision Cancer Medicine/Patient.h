//
//  Patient.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiagnosticReport, NSManagedObject;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * xmlId;
@property (nonatomic, retain) NSString * mrn;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * birthDate;
@property (nonatomic, retain) NSSet *observations;
@property (nonatomic, retain) DiagnosticReport *diagnosticReport;

+ (instancetype) insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addObservationsObject:(NSManagedObject *)value;
- (void)removeObservationsObject:(NSManagedObject *)value;
- (void)addObservations:(NSSet *)values;
- (void)removeObservations:(NSSet *)values;

@end
