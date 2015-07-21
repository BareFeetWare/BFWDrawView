//
//  BFWStyleKit.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFWStyleKitDrawing;

@interface BFWStyleKit : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Class paintCodeClass; // class exported by PaintCode

@property (nonatomic, copy) NSDictionary *colors;   // @{NSString : UIColor}
@property (nonatomic, copy) NSDictionary *drawings; // @{NSString : BFWStyleKitDrawing}

@property (nonatomic, copy) NSDictionary *parameterDict;
@property (nonatomic, copy) NSDictionary *drawParameterDict;

#pragma mark - class methods

+ (NSDictionary *)styleKits;
+ (instancetype)styleKitForName:(NSString *)name;
+ (BFWStyleKitDrawing *)drawingForStyleKitName:(NSString *)styleKitName
                                   drawingName:(NSString *)drawingName;

#pragma mark - Android accessors

- (NSString *)colorsXmlString;

#pragma mark - instance methods

- (UIColor *)colorForName:(NSString *)colorName;
- (BFWStyleKitDrawing *)drawingForName:(NSString *)drawingName;

@end
