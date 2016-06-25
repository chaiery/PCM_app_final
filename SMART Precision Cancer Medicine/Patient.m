//
//  Patient.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "Patient.h"
#import "DiagnosticReport.h"


@implementation Patient

@dynamic xmlId;
@dynamic mrn;
@dynamic firstName;
@dynamic lastName;
@dynamic gender;
@dynamic birthDate;
@dynamic observations;
@dynamic diagnosticReport;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Patient"
                                         inManagedObjectContext:context];
}

@end
