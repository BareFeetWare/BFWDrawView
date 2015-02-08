//
//  BFWDrawButton.h
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import <UIKit/UIKit.h>

@class BFWDrawView;

@interface BFWDrawButton : UIButton

#pragma mark - init

- (void)commonInit; // called by initWithFrame, initWithCode, prepareForInterfaceBuilder. Optionally implement in sublcasses.

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state;
- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state;
- (void)setIconDrawView:(BFWDrawView *)drawView forState:(UIControlState)state;
- (void)setBackgroundDrawView:(BFWDrawView *)drawView forState:(UIControlState)state;

@end
