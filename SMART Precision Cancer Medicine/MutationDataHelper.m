//
//  MutationDataHelper.m
//  SMART Genomics Precision Cancer Medicine
//
//  Created by Daniel Carbone on 9/25/14.
//  Copyright (c) 2014 Vanderbilt-Ingram Cancer Center. All rights reserved.
// 
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

#import "MutationDataHelper.h"

static NSArray *mutationPieSliceColors;
static NSArray *mutationPieLabelColors;
static NSDictionary *mutationReferenceURLs;
static long pieColorCount;

@implementation MutationDataHelper

- (id) init
{
    self = [super init];
    
    if (self)
    {
        if (!mutationPieSliceColors)
        {
            mutationPieSliceColors = @[[UIColor colorWithRed:166.0f/255.0f green:206.0f/255.0f blue:227.0f/255.0f alpha:1.0f],   //A6CEE3
                                       [UIColor colorWithRed:31.0f/255.0f green:120.0f/255.0f blue:180.0f/255.0f alpha:1.0f],    //1F78B4
                                       [UIColor colorWithRed:178.0f/255.0f green:223.0f/255.0f blue:128.0f/255.0f alpha:1.0f],   //B2DF8A
                                       [UIColor colorWithRed:51.0f/255.0f green:160.0f/255.0f blue:44.0f/255.0f alpha:1.0f],     //33A02C
                                       [UIColor colorWithRed:251.0f/255.0f green:154.0f/255.0f blue:153.0f/255.0f alpha:1.0f],   //FB9A99
                                       [UIColor colorWithRed:227.0f/255.0f green:26.0f/255.0f blue:28.0f/255.0f alpha:1.0f],     //E31A1C
                                       [UIColor colorWithRed:253.0f/255.0f green:191.0f/255.0f blue:111.0f/255.0f alpha:1.0f],   //FDBF6F
                                       [UIColor colorWithRed:1.0f green:127.0f/255.0f blue:0.0f alpha:1.0f],                     //FF7F00
                                       [UIColor colorWithRed:202.0f/255.0f green:128.0f/255.0f blue:214.0f/255.0f alpha:1.0f],   //CAB2D6
                                       [UIColor colorWithRed:106.0f/255.0f green:61.0f/255.0f blue:154.0f/255.0f alpha:1.0f],    //6A3D9A
                                       [UIColor colorWithRed:1.0f green:1.0f blue:153.0f/255.0f alpha:1.0f],                     //FFFF99
                                       [UIColor colorWithRed:177.0f/255.0f green:89.0f/255.0f blue:40.0f/255.0f alpha:1.0f],     //B15928
                                       ];
            
            mutationPieLabelColors = @[[UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       [UIColor blackColor],
                                       ];
            
            mutationReferenceURLs = @{@"akt1": @{@"c.49g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/akt1/23/"],},
                                      @"braf": @{@"c.1397g>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/braf/70/"],
                                                 @"c.1799t>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/braf/54/"],},
                                      @"kras": @{@"c.182a>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/42/"],
                                                 @"c.183a>c": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/30/"],
                                                 @"c.183a>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/31/"],
                                                 @"c.34g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/36/"],
                                                 @"c.34g>c": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/35/"],
                                                 @"c.34g>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/33/"],
                                                 @"c.35g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/34/"],
                                                 @"c.35g>c": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/32/"],
                                                 @"c.35g>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/37/"],
                                                 @"c.37g>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/38/"],
                                                 @"c.38g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/kras/39/"],},
                                      @"nras": @{@"c.182a>g": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/nras/77/"],
                                                 @"c.182a>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/melanoma/nras/76/"],
                                                 @"c.35g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/nras/87/"],},
                                      @"pik3ca": @{@"c.1624g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/pik3ca/7/"],
                                                   @"c.1633g>c": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/pik3ca/9/"],
                                                   @"c.3140a>g": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/pik3ca/11/"],},
                                      @"smad4": @{@"c.1081c>t": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/smad4/157/"],
                                                  @"c.1082g>a": [NSURL URLWithString:@"http://www.mycancergenome.org/content/disease/colorectal-cancer/smad4/158/"],},};
            
            pieColorCount = [mutationPieSliceColors count];
        }
    }
    
    return self;
}

- (UIColor *)mutationColorWithIndex:(NSUInteger)index
{
    long colorIndex;
    if (index > (pieColorCount-1))
        colorIndex = index % pieColorCount ;
    else
        colorIndex = index;
    
    return mutationPieSliceColors[colorIndex];
}

- (UIColor *)mutationLabelColorWithIndex:(NSUInteger)index
{
    long colorIndex;
    
    if (index > (pieColorCount-1))
        colorIndex = index % pieColorCount;
    else
        colorIndex = index;
    
    return mutationPieLabelColors[colorIndex];
}

- (NSString *)mutationDisplayValue:(NSString *)mutation
{
    if ([mutation isEqualToString:@"-"])
        return @"Not Detected";
    
    return mutation;
}

- (NSURL *)getReferenceURLForSequenceVariation:(NSString *)mutation inGene:(NSString *)gene
{
    NSDictionary *geneDict;
    NSURL *url;
    if ((geneDict = [mutationReferenceURLs objectForKey:[gene lowercaseString]]) && (url = [geneDict objectForKey:[mutation lowercaseString]])) {
        return url;
    } else {
        return nil;
    }
}

@end
