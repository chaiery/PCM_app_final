//
//  DiagnosticReport.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/24/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "DiagnosticReport.h"


@implementation DiagnosticReport

@dynamic conclusion;
@dynamic xmlId;
@dynamic subject;
@dynamic results;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"DiagnosticReport"
                                         inManagedObjectContext:context];
}

@end
