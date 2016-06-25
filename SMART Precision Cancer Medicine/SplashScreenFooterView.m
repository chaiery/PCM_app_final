//
//  SplashScreenFooterView.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "SplashScreenFooterView.h"

@interface SplashScreenFooterView()

@property (nonatomic, strong) UIImageView *poweredByVanderbilt;
@property (nonatomic, strong) UIImageView *smallSMARTLogo;
@property (nonatomic, strong) UIImageView *smallFHIRLogo;
@property (nonatomic, strong) UIImageView *tjMartellLogo;
@property (nonatomic, strong) UILabel *copyright;

@end

@implementation SplashScreenFooterView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setupSubViews];
        [self setupConstraints];
    }
    return self;
}

- (void) setupSubViews
{
    
    _poweredByVanderbilt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByVanderbilt"]];
    _poweredByVanderbilt.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_poweredByVanderbilt];
    
    _copyright = [[UILabel alloc] init];
    _copyright.translatesAutoresizingMaskIntoConstraints = NO;
    _copyright.textAlignment = NSTextAlignmentCenter;
    _copyright.font = [UIFont systemFontOfSize:12.0f];
    _copyright.text = @"Copyright \u00A9 2014-2015 Vanderbilt-Ingram Cancer Center";
    [self addSubview:_copyright];
    
    _smallSMARTLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SMARTSmall"]];
    _smallSMARTLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_smallSMARTLogo];
    
    _smallFHIRLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FHIRSmall"]];
    _smallFHIRLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_smallFHIRLogo];
    
    _tjMartellLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TJMartellLogo"]];
    _tjMartellLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_tjMartellLogo];
}

- (void) setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_smallSMARTLogo]-30-[_smallFHIRLogo]-30-[_tjMartellLogo]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_smallSMARTLogo, _smallFHIRLogo, _tjMartellLogo)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_poweredByVanderbilt]-25-[_copyright]-120-[_smallFHIRLogo]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_poweredByVanderbilt, _copyright, _smallFHIRLogo)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_smallFHIRLogo
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:-45.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_copyright
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_poweredByVanderbilt
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
