//
//  Observation.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "Observation.h"
#import "DiagnosticReport.h"
#import "Patient.h"


@implementation Observation

@dynamic xmlId;
@dynamic referenceAllele;
@dynamic observedAllele;
@dynamic alleleName;
@dynamic assessedCondition;
@dynamic dnaSequenceVariation;
@dynamic geneIdCode;
@dynamic geneIdDisplay;
@dynamic subject;
@dynamic diagnosticReport;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Observation"
                                         inManagedObjectContext:context];
}

- (NSComparisonResult)compareObservation:(Observation *)_observation{
    NSComparisonResult result = [_observation.geneIdDisplay compare:self.geneIdDisplay];
    if (result == NSOrderedSame) {
        result = [self.dnaSequenceVariation compare:_observation.dnaSequenceVariation];
    }
    if (result == NSOrderedAscending){
        result = NSOrderedDescending;
    }else if (result == NSOrderedDescending){
        result = NSOrderedAscending;
    }
    return result;
}
@end
