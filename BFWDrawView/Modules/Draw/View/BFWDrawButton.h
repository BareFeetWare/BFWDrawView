//
//  BFWDrawButton.h
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Permission granted for use by CBA.
//

#import <UIKit/UIKit.h>

@class BFWDrawView;

@interface BFWDrawButton : UIButton

@property (nonatomic, copy) IBInspectable NSString *styleKit;

@property (nonatomic, copy) NSDictionary *backgroundDrawNameDict;
@property (nonatomic, assign) UIViewContentMode backgroundContentMode;

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state;
- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state;
- (void)setIconDrawView:(BFWDrawView *)drawView forState:(UIControlState)state;
- (void)setBackgroundDrawView:(BFWDrawView *)drawView forState:(UIControlState)state;

@end
