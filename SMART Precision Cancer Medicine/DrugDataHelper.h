//
//  DrugDataHelper.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/30/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrugDataHelper : NSObject

- (NSURL *)drugReferenceURLForDisease:(NSString *)disease;
- (NSURL *)drugReferenceURLForGene:(NSString *)gene;

- (UIImage *)imageForDisease:(NSString *)disease;

@end
