//
//  DrugDataHelper.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/30/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "DrugDataHelper.h"

static NSDictionary *diseaseDrugReferenceMap;
static NSDictionary *geneDrugReferenceMap;
static NSDictionary *diseaseImageMap;

static UIImage *defaultDiseaseImage;

@implementation DrugDataHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!diseaseDrugReferenceMap) {
            diseaseDrugReferenceMap = @{@"Colorectal Cancer": @"http://hemonc.org/wiki/Colon_cancer",};
            
            geneDrugReferenceMap = @{@"AKT1": @"http://hemonc.org/wiki/Category:AKT1_inhibitors",
                                     @"BRAF": @"http://hemonc.org/wiki/Category:BRAF_inhibitors",
                                     @"CTNNB1": @"http://hemonc.org/wiki/Category:CTNNB1_inhibitors",
                                     @"DNMT3A": @"http://hemonc.org/wiki/Category:DNMT3A_inhibitors",
                                     @"EGFR": @"http://hemonc.org/wiki/Category:EGFR_inhibitors",
                                     @"ERBB2": @"http://hemonc.org/wiki/Category:ERBB2_inhibitors",
                                     @"FLT3": @"http://hemonc.org/wiki/Category:FLT3_inhibitors",
                                     @"GNA11": @"http://hemonc.org/wiki/Category:GNA11_inhibitors",
                                     @"GNAQ": @"http://hemonc.org/wiki/Category:GNAQ_inhibitors",
                                     @"IDH1": @"http://hemonc.org/wiki/Category:IDH1_inhibitors",
                                     @"IDH2": @"http://hemonc.org/wiki/Category:IDH2_inhibitors",
                                     @"KIT": @"http://hemonc.org/wiki/Category:KIT_inhibitors",
                                     @"KRAS": @"http://hemonc.org/wiki/Category:KRAS_inhibitors",
                                     @"MAP2K1": @"http://hemonc.org/wiki/Category:MAP2K1_inhibitors",
                                     @"NPM1": @"http://hemonc.org/wiki/Category:NPM1_inhibitors",
                                     @"NRAS": @"http://hemonc.org/wiki/Category:NRAS_inhibitors",
                                     @"PIK3CA": @"http://hemonc.org/wiki/Category:PIK3CA_inhibitors",
                                     @"PTEN": @"http://hemonc.org/wiki/Category:PTEN_inhibitors",
                                     @"SMAD4": @"http://hemonc.org/wiki/Category:SMAD4_inhibitors",
                                     };
            
            defaultDiseaseImage = [UIImage imageNamed:@"DiseaseDefault"];
            
            diseaseImageMap = @{@"Colorectal Cancer": [UIImage imageNamed:@"DiseaseColon"]};
        }
    }
    return self;
}

- (NSURL *)drugReferenceURLForDisease:(NSString *)disease
{
    NSString *url = [diseaseDrugReferenceMap objectForKey:disease];
    if (url) {
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

-(NSURL *)drugReferenceURLForGene:(NSString *)gene
{
    NSString *url = [geneDrugReferenceMap objectForKey:gene];
    if (url) {
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

- (UIImage *)imageForDisease:(NSString *)disease
{
    UIImage *image = [diseaseImageMap objectForKey:disease];;
    if (image) {
        return image;
    } else {
        return defaultDiseaseImage;
    }
}

@end
