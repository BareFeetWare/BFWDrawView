//
//  BFWDrawView.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import <UIKit/UIKit.h>

@class BFWStyleKitDrawing;

IB_DESIGNABLE

@interface BFWDrawView : UIView

@property (nonatomic, strong, nullable) BFWStyleKitDrawing *drawing;
@property (nonatomic, readonly) BOOL canDraw;
@property (nonatomic, copy, nullable) NSArray *parameters;

- (void)setNeedsDraw;

#pragma mark - for subclasses to call or override

@property (nonatomic, readonly) CGFloat animationBetweenStartAndEnd;
@property (nonatomic, readonly) CGRect drawFrame;
- (BOOL)updateArgumentForParameter:( NSString * _Nonnull)parameter;
- (void)copyPropertiesFromView:(UIView * _Nonnull)view;

@end
