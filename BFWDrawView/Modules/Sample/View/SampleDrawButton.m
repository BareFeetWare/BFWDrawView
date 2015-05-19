//
//  SampleDrawButton.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 13/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "SampleDrawButton.h"
#import "SampleStyleKit.h"

@implementation SampleDrawButton

- (void)commonInit
{
    [super commonInit];
    [self makeBackgroundDrawViewsFromStateNameDict:@{@(UIControlStateNormal) : @"Button",
                                                     @(UIControlStateHighlighted) : @"Button Highlighted"}
                                          styleKit:@"SampleStyleKit"];
    [self setShadow:[SampleStyleKit buttonShadow]
           forState:UIControlStateNormal];
    [self setShadow:[SampleStyleKit buttonShadowHighlighted]
           forState:UIControlStateHighlighted];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(80.0, 44.0);
}

@end
