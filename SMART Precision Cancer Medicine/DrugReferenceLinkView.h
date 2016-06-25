//
//  DrugReferenceLinkView.h
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/1/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrugReferenceLinkView : UIView

@property (nonatomic, strong) UIButton *diseaseReferenceButton;
@property (nonatomic, strong) UIButton *geneReferenceButton;

@property (nonatomic, strong) UIButton *diseaseImage;
@property (nonatomic, strong) UIButton *geneImage;

- (instancetype)initWithDisease:(NSString *)disease andGene:(NSString *)gene;

@end
