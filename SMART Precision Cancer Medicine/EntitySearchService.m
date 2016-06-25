//
//  EntitySearchService.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/25/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "EntitySearchService.h"
#import "Patient.h"
#import "Observation.h"

@implementation EntitySearchService

#pragma mark - Helper methods

- (NSFetchRequest *)createEntityFetchRequest:(NSString *)entityName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_moc];
    [fetchRequest setEntity:entity];
    return fetchRequest;
}

- (NSUInteger)countEntity:(NSString *)entityName
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:entityName];
    [fetchRequest setIncludesSubentities:NO];
    
    NSError *error;
    return [_moc countForFetchRequest:fetchRequest
                                error:&error];
}

#pragma mark - Search methods

- (NSArray *)searchForPatientsByDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(observations, $o, $o.assessedCondition = %@).@count >= %d", disease, 1];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    return [_moc executeFetchRequest:fetchRequest error:&error];
    
}

- (NSArray *)searchForPatientsByNameOrMRN:(NSString *)text
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    [fetchRequest setIncludesSubentities:NO];
    
    if (text) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([text length] >= 1) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"lastName BEGINSWITH[cd] %@ OR firstName BEGINSWITH[cd] %@ OR mrn BEGINSWITH[cd] %@", text, text, text]];
        }
    }
    
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSArray *sorters = [[NSArray alloc] initWithObjects:lastNameSorter, firstNameSorter, nil];
    [fetchRequest setSortDescriptors:sorters];
    
    NSError *error;
    NSArray *results = [_moc executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Patient Search error ocurred: %@, %@", error, [error localizedDescription]);
        return nil;
    } else {
        return results;
    }
}

- (NSArray *)searchObservationsByGeneIdDisplay:(NSString *)geneName andDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Observation"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(assessedCondition = %@) AND (geneIdDisplay = %@)", disease, geneName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    return [_moc executeFetchRequest:fetchRequest error:&error];
}

#pragma mark - Counting methods

- (NSNumber *)countPatientsWithAnyMutationOnGene:(NSString *)geneName inDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(observations, $o, $o.assessedCondition = %@ AND $o.geneIdDisplay = %@ AND ($o.dnaSequenceVariation != %@ AND $o.dnaSequenceVariation != nil)).@count >= %d", disease, geneName, @"-", 1];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    return [NSNumber numberWithUnsignedInteger:[_moc countForFetchRequest:fetchRequest error:&error]];
}

- (NSNumber *)countPatientsWithNoMutationsDetectedInDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(diagnosticReport, $dr, $dr.conclusion = %@).@count == %d", @"No mutations detected on tested genes.", 1];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSUInteger count = [_moc countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error occurred while searching for \"Not Detected\" patients.  Error: %@, %@.", error, [error localizedDescription]);
        return nil;
    } else {
        return [NSNumber numberWithUnsignedInteger:count];
    }
}

- (NSNumber *)countPatientsWithDNASequenceVariation:(NSString *)mutation inGene:(NSString *)gene inDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    [fetchRequest setReturnsObjectsAsFaults:NO];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(observations, $o, $o.assessedCondition = %@ AND $o.geneIdDisplay = %@ AND $o.dnaSequenceVariation = %@).@count >= %d", disease, gene, mutation, 1];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSUInteger count = [_moc countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error occurred while counting patients with \"%@\" mutation in \"%@\" in \"%@\". Error: %@, %@", mutation, gene, disease, error, [error localizedDescription]);
        return nil;
    } else {
        return [NSNumber numberWithUnsignedInteger:count];
    }
}

#pragma mark - List methods

- (NSArray *)getAllGenesForDisease:(NSString *)disease;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Observation"
                                              inManagedObjectContext:_moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"geneIdDisplay"]]];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"geneIdDisplay" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sorter]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assessedCondition = %@", disease];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [_moc executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error occurred while getting gene list.  Error: %@, %@", error, [error localizedDescription]);
        return nil;
    } else {
        __block NSMutableArray *geneNames = [[NSMutableArray alloc] init];
        __block NSString *geneName;
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ((geneName = [obj objectForKey:@"geneIdDisplay"])) {
                [geneNames addObject:geneName];
            }
        }];
        return geneNames;
    }
}

- (NSDictionary *)getAllMutationsForGene:(NSString *)gene inDisease:(NSString *)disease
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Observation"
                                              inManagedObjectContext:_moc];
    NSDictionary *properties = [entity propertiesByName];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:properties[@"dnaSequenceVariation"], properties[@"alleleName"], nil]];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"dnaSequenceVariation" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sorter]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assessedCondition = %@ AND geneIdDisplay = %@ AND dnaSequenceVariation != %@ AND dnaSequenceVariation != nil", disease, gene, @"-"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [_moc executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error occurred while getting mutations for \"%@\". Error: %@, %@", gene, error, [error localizedDescription]);
        return nil;
    } else {
        __block NSMutableDictionary *mutations = [[NSMutableDictionary alloc] init];
        __block NSString *dnaSequenceVariation, *alleleName;
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dnaSequenceVariation = [obj objectForKey:@"dnaSequenceVariation"];
            alleleName = [obj objectForKey:@"alleleName"];
            if (dnaSequenceVariation && alleleName) {
                [mutations setObject:alleleName forKey:dnaSequenceVariation];
            }
        }];
        return mutations;
    }
}


- (BOOL)deletePatientByMRN:(NSString *)mrn
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    NSUndoManager *undoManager = [_moc undoManager];
    [_moc setUndoManager:nil];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mrn = %@", mrn];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_moc executeFetchRequest:fetchRequest
                                         error:&error];
    
    if (items && [items count] > 0) {
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_moc deleteObject:obj];
        }];
        
        if ([_moc save:&error]) {
            [_moc setUndoManager:undoManager];
            return YES;
        } else {
            NSLog(@"Error encountered during CoreData purge: %@, %@", error, [error localizedDescription]);
            return NO;
        }
    } else {
        return YES;
    }
}

#pragma mark - Purge method

- (BOOL)purgeCoreData
{
    NSFetchRequest *fetchRequest = [self createEntityFetchRequest:@"Patient"];
    NSUndoManager *undoManager = [_moc undoManager];
    [_moc setUndoManager:nil];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *items = [_moc executeFetchRequest:fetchRequest
                                         error:&error];
    
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_moc deleteObject:obj];
    }];
    
    if ([_moc save:&error]) {
        [_moc setUndoManager:undoManager];
        return YES;
    } else {
        NSLog(@"Error encountered during CoreData purge: %@, %@", error, [error localizedDescription]);
        return NO;
    }
}

@end
