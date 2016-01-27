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

@property (nonatomic, copy) NSArray *classMethodNames; // @[NSString]
@property (nonatomic, copy) NSArray *colorNames; // @[NSString]
@property (nonatomic, copy) NSArray *drawingNames; // @[NSString]

@property (nonatomic, copy) NSDictionary *parameterDict;
@property (nonatomic, copy) NSDictionary *drawParameterDict;

#pragma mark - class methods

+ (NSArray *)styleKitNames;
+ (instancetype)styleKitForName:(NSString *)name;
+ (BFWStyleKitDrawing *)drawingForStyleKitName:(NSString *)styleKitName
                                   drawingName:(NSString *)drawingName;

#pragma mark - instance methods

- (UIColor *)colorForName:(NSString *)colorName;
- (BFWStyleKitDrawing *)drawingForName:(NSString *)drawingName;
- (NSString *)classMethodNameForDrawingName:(NSString *)drawingName;

#pragma mark - Android export

+ (NSString *)colorsXmlForStyleKits:(NSArray *)styleKits;

@end
