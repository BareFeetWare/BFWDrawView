//
//  UIColor+BFW.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 18/05/2015.
//  Triggered by refactoring by Tom Jowett on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "UIColor+BFW.h"

@implementation UIColor (BFW)

- (NSString *)hexFromFraction:(CGFloat)fraction
{
    NSUInteger valueInt = round(fraction * 255.0);
    NSString *hexString = [NSString stringWithFormat:@"%02lx", (unsigned long)valueInt];
    return hexString;
}

- (NSString *)hexStringIncludingAlpha:(BOOL)includingAlpha
{
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    if (self == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        red = 1.0;
        green = 1.0;
        blue = 1.0;
        alpha = 1.0;
    }
    else {
        [self getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    
    NSString *redHex = [self hexFromFraction:red];
    NSString *blueHex = [self hexFromFraction:blue];
    NSString *greenHex = [self hexFromFraction:green];
    
    NSArray *hexArray = @[redHex, greenHex, blueHex];
    if (includingAlpha) {
        NSString *alphaHex = [self hexFromFraction:alpha];
        hexArray = [@[alphaHex] arrayByAddingObjectsFromArray:hexArray];
    }
    NSString *colorHex = [hexArray componentsJoinedByString:@""];
    return colorHex;
}

- (NSString *)hexString
{
    return [self hexStringIncludingAlpha:YES];
}

- (NSString *)cssHexString
{
    return [self hexStringIncludingAlpha:NO];
}

@end
