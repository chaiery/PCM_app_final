//
//  DiagnosticReport.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface DiagnosticReport : NSManagedObject

@property (nonatomic, retain) NSString * conclusion;
@property (nonatomic, retain) NSString * xmlId;
@property (nonatomic, retain) NSManagedObject *subject;
@property (nonatomic, retain) NSSet *results;

+ (instancetype) insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end

@interface DiagnosticReport (CoreDataGeneratedAccessors)

- (void)addResultsObject:(NSManagedObject *)value;
- (void)removeResultsObject:(NSManagedObject *)value;
- (void)addResults:(NSSet *)values;
- (void)removeResults:(NSSet *)values;

@end
