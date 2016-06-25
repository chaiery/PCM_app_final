//
//  SplashScreenView.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 4/22/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "SplashScreenView.h"
#import "SplashScreenFooterView.h"

@interface SplashScreenView()

@property (nonatomic, strong) UIImageView *appLogo;
@property (nonatomic, strong) SplashScreenFooterView *footer;

// I'm sure there is a better way to do this...
@property BOOL layouted;

@end

@implementation SplashScreenView

- (id) init
{
    self = [super init];
    if (self) {
        
        _layouted = NO;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
        _appLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo"]];
        _appLogo.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_appLogo];
        
        _footer = [[SplashScreenFooterView alloc] init];
        [self addSubview:_footer];
    }
    return self;
}

- (BOOL)needsUpdateConstraints
{
    return !_layouted;
}

- (void)layoutSubviews
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_appLogo
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_footer]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_footer)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-75-[_appLogo]-(>=20)-[_footer]-50-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_appLogo, _footer)]];
    
    [super layoutSubviews];
    
    _layouted = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
