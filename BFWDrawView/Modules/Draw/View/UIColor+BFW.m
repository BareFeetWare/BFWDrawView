//
//  UIColor+BFW.m
//  BFWDrawView
//
//  Created by Tom Jowett on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "UIColor+BFW.h"

@implementation UIColor (BFW)

- (NSString *)cssHexString
{
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSUInteger redInt = round(red * 255.0);
    NSUInteger greenInt = round(green * 255.0);
    NSUInteger blueInt = round(blue * 255.0);
    
    NSString *hexString = [NSString stringWithFormat:@"%02lx%02lx%02lx", (unsigned long)redInt, (unsigned long)greenInt, (unsigned long)blueInt];
    
    return hexString;
}

@end
