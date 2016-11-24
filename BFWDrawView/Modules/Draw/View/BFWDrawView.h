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

@property (nonatomic, copy) IBInspectable NSString *name;
@property (nonatomic, copy) IBInspectable NSString *styleKit;

@property (nonatomic, strong) BFWStyleKitDrawing *drawing;

@property (nonatomic, strong) UIColor *fillColor; // Deprecated. Use UIView's tintColor
@property (nonatomic, readonly) CGSize drawnSize; // Deprecated. Use self.drawing.drawnSize

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) BOOL canDraw;

@property (nonatomic, copy) NSArray *parameters;

#pragma mark - image output methods

- (BOOL)writeImageAtScale:(CGFloat)scale
                 isOpaque:(BOOL)isOpaque
                   toFile:(NSString *)savePath;

#pragma mark - for subclasses to call or override

- (BOOL)updateArgumentForParameter:(NSString *)parameter;
- (void)copyPropertiesFromView:(BFWDrawView *)view;
@property (nonatomic, readonly) CGFloat animationBetweenStartAndEnd;

@end
