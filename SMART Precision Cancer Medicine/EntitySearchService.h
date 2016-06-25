//
//  EntitySearchService.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/25/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntitySearchService : NSObject

@property (nonatomic, weak) NSManagedObjectContext *moc;

- (NSUInteger)countEntity:(NSString *)entityName;

- (NSArray *)searchForPatientsByNameOrMRN:(NSString *)text;
- (NSArray *)searchObservationsByGeneIdDisplay:(NSString *)geneName andDisease:(NSString *)disease;
- (NSArray *)searchForPatientsByDisease:(NSString *)disease;

- (NSNumber *)countPatientsWithAnyMutationOnGene:(NSString *)geneName inDisease:(NSString *)disease;
- (NSNumber *)countPatientsWithNoMutationsDetectedInDisease:(NSString *)disease;
- (NSNumber *)countPatientsWithDNASequenceVariation:(NSString *)mutation inGene:(NSString *)gene inDisease:(NSString *)disease;

- (NSArray *)getAllGenesForDisease:(NSString *)disease;
- (NSDictionary *)getAllMutationsForGene:(NSString *)gene inDisease:(NSString *)disease;

- (BOOL)deletePatientByMRN:(NSString *)mrn;
- (BOOL)purgeCoreData;

@end
