//
//  LoadPatientResources.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "PatientResourceLoader.h"

#import "Patient.h"
#import "Observation.h"
#import "DiagnosticReport.h"

#define fhirServerEndpoint @"http://localhost/asco/"

typedef enum {
    queryingForPatientResourceFileList,
    queryingForPatientResourceFile
} ResourceLoaderState;

typedef enum {
    inPatientResource,
    inObservationResource,
    inDiagnosticReportResource,
    outsideResource,
} ResourceXMLParserState;

typedef enum {
    patientRootElement,
    patientTextElement,
    patientNameElement,
    patientGenderElement,
    patientBirthdateElement,
} PatientResourceElements;

typedef enum {
    observationRootElement,
    observationExtensionReferenceAlleleElement,
    observationExtensionObservedAlleleElement,
    observationExtensionAlleleNameElement,
    observationExtensionAssessedConditionElement,
    observationExtensionDNASequenceVariationElement,
    observationExtensionGeneIdElement,
    observationTextElement,
    observationValueCodeableConceptElement,
    observationSubjectElement,
} ObservationResourceElements;

typedef enum {
    diagnosticReportRootElement,
    diagnosticReportSubjectElement,
    diagnosticReportResultElement,
    diagnosticReportConclusionElement,
    diagnosticReportCodedDiagnosisElement,
} DiagnosticReportElements;

@interface PatientResourceLoader()

@property (nonatomic, strong) NSArray *resourceFileList;
@property (nonatomic, strong) NSNumber *resourceFileCount;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic) long currentIndex;
@property (nonatomic, strong) NSString *currentFilename;

@property (nonatomic, strong) Patient *patient;
@property (nonatomic, strong) NSMutableArray *observations;
@property (nonatomic, strong) Observation *currentObservation;
@property (nonatomic, strong) DiagnosticReport *diagnosticReport;

@end

static NSArray *patientElements;
static NSArray *observationElements;
static NSArray *diagnosticReportElements;

@implementation PatientResourceLoader

ResourceLoaderState loaderStateEnum;
ResourceXMLParserState parserStateEnum;
PatientResourceElements patientElementEnum;
ObservationResourceElements observationElementEnum;
DiagnosticReportElements diagnosticReportElementEnum;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentIndex = -1;
        _observations = [[NSMutableArray alloc] init];
        if (!patientElements) {
            patientElements = @[@"Patient",
                                @"text",
                                @"name",
                                @"gender",
                                @"birthDate"];
            observationElements = @[@"Observation",
                                    @"extension",
                                    @"extension",
                                    @"extension",
                                    @"extension",
                                    @"extension",
                                    @"extension",
                                    @"text",
                                    @"valueCodeableConcept",
                                    @"subject"];
            diagnosticReportElements = @[@"DiagnosticReport",
                                         @"subject",
                                         @"result",
                                         @"conclusion",
                                         @"codedDiagnosis"];
        }
    }
    return self;
}

- (void)reset
{
    _patient = nil;
    _currentObservation = nil;
    [_observations removeAllObjects];
    _diagnosticReport = nil;
}

#pragma mark - Remote XML file parsing

- (void)queryFhirServerForPatientResourceXmlFileList
{
    NSString *queryString = fhirServerEndpoint;
    NSURL *queryUrl = [NSURL URLWithString: queryString];
    NSURLRequest *request = [NSURLRequest requestWithURL: queryUrl];
    
    _currentIndex = -1;
    _currentFilename = nil;
    
    loaderStateEnum = queryingForPatientResourceFileList;
    [_delegate queryingForRemotePatientResourceFileList];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)parsePatientFileListResponse
{
    NSError *error;
    NSArray *resourceFiles;
    NSNumber *fileCount;
    
    id json = [NSJSONSerialization JSONObjectWithData:_receivedData options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON parse error: %@", [error localizedDescription]);
        [_delegate resourceLoaderErrorRaised:@"Unable to retrieve Patient Resource File List"];
    } else {
        if ((resourceFiles = [json objectForKey:@"resourceFiles"]) && (fileCount = (NSNumber *)[json objectForKey:@"fileCount"])) {
            _resourceFileList = resourceFiles;
            _resourceFileCount = fileCount;
            [_delegate receivedRemotePatientResourceFileList:_resourceFileList
                                              andCount:_resourceFileCount];
        } else {
            [_delegate resourceLoaderErrorRaised:@"Invalid PatientResourceList JSON response seen."];
            [NSException raise:@"Invalid Patient Resource List response seen" format:@""];
        }
    }
}

- (void)populateCoreDataWithRemotePatientResourceXmlFiles
{
    if (++_currentIndex == [_resourceFileCount longValue]) {
        [_delegate finishedImportingPatientResources];
    } else {
        _currentFilename = _resourceFileList[_currentIndex];
        
        NSString *queryString = [NSString stringWithFormat:@"%@file/%@", fhirServerEndpoint, _currentFilename];
        NSURL *queryUrl = [NSURL URLWithString:queryString];
        NSURLRequest *request = [NSURLRequest requestWithURL:queryUrl];
        
        loaderStateEnum = queryingForPatientResourceFile;
        [_delegate importingRemotePatientResouce:_currentFilename
                                   atIndex:_currentIndex
                                   ofTotal:[_resourceFileCount longValue]];
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)remotePatientDataReceived
{
    [self parseResourcesFromXMLString:[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding]];
}

#pragma mark - Local XML File Parsing

- (void)locateLocalPatientResourceXmlFiles
{
    _currentIndex = -1;
    _currentFilename = nil;
    _resourceFileList = [[NSBundle mainBundle] pathsForResourcesOfType:@"xml" inDirectory:nil];
    
    if (_resourceFileList == nil || [_resourceFileList count] == 0) {
        NSLog(@"Could not locate local Patient resource XML files");
        [_delegate resourceLoaderErrorRaised:@"Could not locate local Patient Resource XML files"];
    } else {
        _resourceFileCount = [NSNumber numberWithLong:[_resourceFileList count]];
        [_delegate locatedLocalPatientResourceXmlFiles:_resourceFileList andCount:_resourceFileCount];
    }
}

// TODO: Finish implementing this
- (void)populateCoreDataFromLocalPatientResourceXmlFiles
{
    if (++_currentIndex == [_resourceFileCount longValue]) {
        [_delegate finishedImportingPatientResources];
    } else {
        _currentFilename = [[_resourceFileList[_currentIndex] componentsSeparatedByString:@"/"] lastObject];
        [_delegate importingLocalPatientResource:_currentFilename
                                         atIndex:_currentIndex
                                         ofTotal:[_resourceFileCount longValue]];
        [self parseResourcesFromXMLInputStream: [NSInputStream inputStreamWithFileAtPath:_resourceFileList[_currentIndex]]];
    }
}

#pragma mark - Patient Data Parsing

- (void)parseResourcesFromXMLString:(NSString *)data
{
    [self reset];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    xmlParser.shouldResolveExternalEntities = NO;
    
    if ([xmlParser parse]) {
        [_delegate finishedImportingRemotePatientResource:_currentFilename
                                                  atIndex:_currentIndex
                                                  ofTotal:[_resourceFileCount longValue]];
    } else {
        [_delegate resourceLoaderErrorRaised:[NSString stringWithFormat:@"Unabled to parse resource XML for \"%@\"", _currentFilename]];
        NSLog(@"Unable to parse patient \"%@\" resource XML.  Erro: %@, %@", _currentFilename, [xmlParser parserError], [[xmlParser parserError] localizedDescription]);
    }
}

- (void)parseResourcesFromXMLInputStream:(NSInputStream *)data
{
    [self reset];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithStream:data];
    [xmlParser setDelegate:self];
    xmlParser.shouldResolveExternalEntities = NO;
    
    if ([xmlParser parse]) {
        [_delegate finishedImportingLocalPatientResource:_currentFilename
                                                 atIndex:_currentIndex
                                                 ofTotal:[_resourceFileCount longValue]];
    } else {
        [_delegate resourceLoaderErrorRaised:[NSString stringWithFormat:@"Unabled to parse resource XML for \"%@\"", _currentFilename]];
        NSLog(@"Unable to parse patient \"%@\" resource XML.  Erro: %@, %@", _currentFilename, [xmlParser parserError], [[xmlParser parserError] localizedDescription]);
    }
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    switch(loaderStateEnum) {
        case queryingForPatientResourceFileList:
            [self parsePatientFileListResponse];
            break;
        case queryingForPatientResourceFile :
            [self remotePatientDataReceived];
            break;
    }
}

#pragma mark - Object Population methods

- (void)parsePatientData:(NSXMLParser *)parser
             fromElement:(NSString *)elementName
          withAttributes:(NSDictionary *)attributeDict
{
    NSString *value;
    NSArray *split;
    
    long idx = (long)[patientElements indexOfObject:elementName];
    if (idx != NSNotFound) {
        patientElementEnum = (int)idx;
    }
    
    switch (patientElementEnum) {
        case patientRootElement:
            if ((value = [attributeDict objectForKey:@"id"])) {
                split = [value componentsSeparatedByString:@"/"];
                if ([split count] == 2) {
                    [_patient setValue:(NSString *)split[1] forKey:@"mrn"];
                }
                [_patient setValue:value forKey:@"xmlId"];
            }
            break;
        case patientNameElement:
            if ([elementName isEqualToString:@"family"] && (value = [attributeDict objectForKey:@"value"])) {
                [_patient setValue:value forKey:@"lastName"];
            } else if ([elementName isEqualToString:@"given"] && (value = [attributeDict objectForKey:@"value"])) {
                [_patient setValue:value forKey:@"firstName"];
            }
            break;
        case patientGenderElement:
            if ([elementName isEqualToString:@"display"] && (value = [attributeDict objectForKey:@"value"])) {
                if (1 == [value length]) {
                    if ([[value lowercaseString] isEqualToString:@"m"]) {
                        value = @"Male";
                    } else if ([[value lowercaseString] isEqualToString:@"f"]) {
                        value = @"Female";
                    }
                }
                [_patient setValue:value forKey:@"gender" ];
            }
            break;
        case patientBirthdateElement:
            if((value = [attributeDict objectForKey:@"value"])) {
                if (NSNotFound != [value rangeOfString:@"T"].location) {
                    value = [[value componentsSeparatedByString:@"T"] firstObject];
                }
                
                [_patient setValue:value forKey:@"birthDate"];
            }
        default:
            break;
    }
}

- (void)parseObservationData:(NSXMLParser *)parser
                 fromElement:(NSString *)elementName
              withAttributes:(NSDictionary *)attributeDict
{
    NSString *value;
    
    if ([elementName isEqualToString:@"extension"]) {
        NSString *url = [attributeDict objectForKey:@"url"];
        if (url) {
            if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsReferenceAllele"]) {
                observationElementEnum = observationExtensionReferenceAlleleElement;
            } else if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsObservedAllele"]) {
                observationElementEnum = observationExtensionObservedAlleleElement;
            } else if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsAlleleName"]) {
                observationElementEnum = observationExtensionAlleleNameElement;
            } else if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsAssessedCondition"]) {
                observationElementEnum = observationExtensionAssessedConditionElement;
            } else if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsDNASequenceVariation"]) {
                observationElementEnum = observationExtensionDNASequenceVariationElement;
            } else if ([url isEqualToString:@"http://hl7.org/fhir/StructureDefinition/geneticsGeneId"]) {
                observationElementEnum = observationExtensionGeneIdElement;
            }
        }
    } else if (observationElementEnum == observationRootElement) {
        long idx = (long)[observationElements indexOfObject:elementName];
        if (idx != NSNotFound) {
            observationElementEnum = (int)idx;
        }
    }
    
    switch (observationElementEnum) {
        case observationRootElement:
            if ((value = [attributeDict objectForKey:@"id"])) {
                [_currentObservation setValue:value forKey:@"xmlId"];
            }
            break;
        case observationExtensionGeneIdElement:
            if ([elementName isEqualToString:@"code"] && (value = [attributeDict objectForKey:@"value"])) {
                [_currentObservation setValue:value forKey:@"geneIdCode"];
            } else if ([elementName isEqualToString:@"display"] && (value = [attributeDict objectForKey:@"value"])) {
                [_currentObservation setValue:value forKey:@"geneIdDisplay"];
            }
            break;
        case observationExtensionDNASequenceVariationElement:
            if ([elementName isEqualToString:@"valueString"] && (value = [attributeDict objectForKey:@"value"])) {
                [_currentObservation setValue:value forKey:@"dnaSequenceVariation"];
            }
            break;
        case observationExtensionAssessedConditionElement:
            if ([elementName isEqualToString:@"valueString"] && (value = [attributeDict objectForKey:@"value"])) {
                [_currentObservation setValue:value forKey:@"assessedCondition"];
            }
            break;
        case observationExtensionAlleleNameElement:
            if ([elementName isEqualToString:@"display"] && (value = [attributeDict objectForKey:@"value"])) {
                [_currentObservation setValue:value forKey:@"alleleName"];
            }
            break;
        case observationExtensionReferenceAlleleElement:
            if ([elementName isEqualToString:@"valueString"]) {
                [_currentObservation setValue:value forKey:@"referenceAllele"];
            }
            break;
        case observationExtensionObservedAlleleElement:
            if ([elementName isEqualToString:@"valueString"]) {
                [_currentObservation setValue:value forKey:@"observedAllele"];
            }
            break;
        default:
            break;
    }
}

- (void)parseDiagnosticReportData:(NSXMLParser *)parser
                      fromElement:(NSString *)elementName
                   withAttributes:(NSDictionary *)attributeDict
{
    NSString *value;
    long idx = (long)[diagnosticReportElements indexOfObject:elementName];
    if (idx != NSNotFound) {
        diagnosticReportElementEnum = (int)idx;
    }
    
    switch (diagnosticReportElementEnum) {
        case diagnosticReportRootElement:
            if ((value = [attributeDict objectForKey:@"id"])) {
                [_diagnosticReport setValue:value forKey:@"xmlId"];
            }
            break;
        case diagnosticReportConclusionElement:
            [_diagnosticReport setConclusion:[attributeDict objectForKey:@"value"]];
            break;
        default:
            break;
    }
}

#pragma mark - NSXMLParser implementation

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //    NSLog(@"Begining importing of FHIR Resource Feed");
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Patient"]) {
        parserStateEnum = inPatientResource;
        patientElementEnum = patientRootElement;
        _patient = [Patient insertNewObjectIntoContext:_moc];
    } else if ([elementName isEqualToString:@"Observation"]) {
        parserStateEnum = inObservationResource;
        observationElementEnum = observationRootElement;
        [_observations addObject:[Observation insertNewObjectIntoContext:_moc]];
        _currentObservation = [_observations lastObject];
    } else if ([elementName isEqualToString:@"DiagnosticReport"]) {
        parserStateEnum = inDiagnosticReportResource;
        diagnosticReportElementEnum = diagnosticReportRootElement;
        _diagnosticReport = [DiagnosticReport insertNewObjectIntoContext:_moc];
    }
    
    switch (parserStateEnum) {
        case inPatientResource:
            [self parsePatientData:parser fromElement:elementName withAttributes:attributeDict];
            break;
        case inObservationResource:
            [self parseObservationData:parser fromElement:elementName withAttributes:attributeDict];
            break;
        case inDiagnosticReportResource:
            [self parseDiagnosticReportData:parser fromElement:elementName withAttributes:attributeDict];
            break;
            
        default:
            // do nothing
            break;
    }
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    long idx;
    
    switch (parserStateEnum) {
        case inPatientResource:
            if ([elementName isEqualToString:@"Patient"]) {
                parserStateEnum = outsideResource;
                patientElementEnum = patientRootElement;
            } else {
                switch (patientElementEnum) {
                    case patientNameElement:
                    case patientTextElement:
                    case patientGenderElement:
                    case patientBirthdateElement:
                        idx = (long)[patientElements indexOfObject:elementName];
                        if (idx != NSNotFound && idx == patientElementEnum) {
                            patientElementEnum = patientRootElement;
                        }
                    default:
                        break;
                }
            }
            break;
        case inObservationResource:
            if ([elementName isEqualToString:@"Observation"]) {
                parserStateEnum = outsideResource;
                observationElementEnum = observationRootElement;
            } else {
                switch (observationElementEnum) {
                    case observationValueCodeableConceptElement:
                    case observationTextElement:
                    case observationSubjectElement:
                        idx = [observationElements indexOfObject:elementName];
                        if (idx != NSNotFound && idx == observationElementEnum) {
                            observationElementEnum = observationRootElement;
                        }
                        break;
                    case observationExtensionAssessedConditionElement:
                    case observationExtensionAlleleNameElement:
                    case observationExtensionGeneIdElement:
                    case observationExtensionDNASequenceVariationElement:
                    case observationExtensionObservedAlleleElement:
                    case observationExtensionReferenceAlleleElement:
                        if ([elementName isEqualToString:@"extension"]) {
                            observationElementEnum = observationRootElement;
                        }
                    default:
                        break;
                }
            }
            break;
            
        case inDiagnosticReportResource :
            if ([elementName isEqualToString:@"DiagnosticReport"]) {
                parserStateEnum = outsideResource;
                diagnosticReportElementEnum = diagnosticReportRootElement;
            } else {
                switch (diagnosticReportElementEnum) {
                    case diagnosticReportSubjectElement:
                    case diagnosticReportResultElement:
                    case diagnosticReportConclusionElement:
                    case diagnosticReportCodedDiagnosisElement:
                        idx = [diagnosticReportElements indexOfObject:elementName];
                        if (idx != NSNotFound && idx == diagnosticReportElementEnum) {
                            diagnosticReportElementEnum = diagnosticReportRootElement;
                        }
                        break;
                    default:
                        break;
                }
            }
            break;
            
        default:
            break;
            
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSError *saveError;
    
    [_patient setDiagnosticReport:_diagnosticReport];
    
    [_observations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_patient addObservationsObject:obj];
        [_diagnosticReport addResultsObject:obj];
    }];
    
    if (![_moc save:&saveError]) {
        NSLog(@"Unable to save entities from file \"%@\" to CoreData. Error: %@, %@", _currentFilename, saveError, [saveError localizedDescription]);
        [_delegate resourceLoaderErrorRaised:@"CoreData persistence error seen, please give device to developer for debugging."];
    }
}

@end
