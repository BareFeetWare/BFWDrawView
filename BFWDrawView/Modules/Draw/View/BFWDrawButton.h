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

- (void)commonInit; // called by initWithFrame, initWithCode, prepareForInterfaceBuilder. Optionally implement in subclasses.

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state;
- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state;
- (NSShadow *)shadowForState:(UIControlState)state;
- (void)setIconDrawView:(BFWDrawView *)drawView
               forState:(UIControlState)state;
- (void)setBackgroundDrawView:(BFWDrawView *)drawView
                     forState:(UIControlState)state;
- (void)setShadow:(NSShadow *)shadow
         forState:(UIControlState)state;
// Convenience method, assuming backgrounds all use the same styleKit and should fill frame (contentMode = redraw)
- (void)makeBackgroundDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                       styleKit:(NSString *)styleKit;
// Convenience method, assuming icons all use the same styleKit and have drawnSize
- (void)makeIconDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                  styleKit:(NSString *)styleKit;

@end
