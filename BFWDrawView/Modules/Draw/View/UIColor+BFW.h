//
//  UIColor+BFW.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 18/05/2015.
//  Triggered by refactoring by Tom Jowett on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BFW)

- (NSString *)hexStringIncludingAlpha:(BOOL)includingAlpha;
- (NSString *)hexString;
- (NSString *)cssHexString;

@end
