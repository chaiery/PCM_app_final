//
//  DrugReferenceLinkView.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/1/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "DrugReferenceLinkView.h"
#import "DrugDataHelper.h"

@interface DrugReferenceLinkView()

@property (nonatomic, strong) NSMutableArray *portraitConstraints;
@property (nonatomic, strong) NSMutableArray *landscapeConstraints;

@end

static DrugDataHelper *drugDataHelper;

@implementation DrugReferenceLinkView

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!drugDataHelper) {
            drugDataHelper = [[DrugDataHelper alloc] init];
        }
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        _diseaseReferenceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _diseaseReferenceButton.translatesAutoresizingMaskIntoConstraints = NO;
        _diseaseReferenceButton.titleLabel.font = [UIFont systemFontOfSize:22.0f];
        
        _geneReferenceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _geneReferenceButton.translatesAutoresizingMaskIntoConstraints = NO;
        _geneReferenceButton.titleLabel.font = [UIFont systemFontOfSize:22.0f];
        
        _diseaseImage = [[UIButton alloc] init];
        _diseaseImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _geneImage = [[UIButton alloc] init];
        [_geneImage setImage:[UIImage imageNamed:@"DNA"] forState:UIControlStateNormal];
        _geneImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_diseaseImage];
        [self addSubview:_diseaseReferenceButton];
        [self addSubview:_geneImage];
        [self addSubview:_geneReferenceButton];
        [self constructConstraints];
    }
    return self;
}

- (instancetype)initWithDisease:(NSString *)disease andGene:(NSString *)gene
{
    self = [self init];
    if (self) {
        [_diseaseReferenceButton setTitle:@"Rx by Disease" forState:UIControlStateNormal];
        [_diseaseImage setImage:[drugDataHelper imageForDisease:disease] forState:UIControlStateNormal];
        [_geneReferenceButton setTitle:@"Rx by Gene" forState:UIControlStateNormal];
    }
    return self;
}

- (void)constructConstraints
{
    _portraitConstraints = [[NSMutableArray alloc] initWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[diseaseImage]-[geneImage]|"
                                                                                                         options:NSLayoutFormatAlignAllLeft
                                                                                                         metrics:nil
                                                                                                           views:@{@"diseaseImage": _diseaseImage,
                                                                                                                   @"geneImage": _geneImage}]];
    [_portraitConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[diseaseImage]-[disease]|"
                                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                                      metrics:nil
                                                                                        views:@{@"diseaseImage": _diseaseImage,
                                                                                                @"disease": _diseaseReferenceButton}]];
    [_portraitConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[geneImage]-[gene]"
                                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                                      metrics:nil
                                                                                        views:@{@"geneImage": _geneImage,
                                                                                                @"gene": _geneReferenceButton}]];
    
    _landscapeConstraints = [[NSMutableArray alloc] initWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[diseaseImage]-[disease]-(50)-[geneImage]-[gene]|"
                                                                                                         options:NSLayoutFormatAlignAllCenterY
                                                                                                         metrics:nil
                                                                                                            views:@{@"diseaseImage": _diseaseImage,
                                                                                                                    @"disease": _diseaseReferenceButton,
                                                                                                                    @"geneImage": _geneImage,
                                                                                                                    @"gene": _geneReferenceButton}]];
    [_landscapeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[diseaseImage]|"
                                                                                       options:NSLayoutFormatAlignAllLeft
                                                                                       metrics:nil
                                                                                         views:@{@"diseaseImage": _diseaseImage}]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self removeConstraints:_landscapeConstraints];
        [self addConstraints:_portraitConstraints];
    } else {
        [self removeConstraints:_portraitConstraints];
        [self addConstraints:_landscapeConstraints];
    }
}

@end
