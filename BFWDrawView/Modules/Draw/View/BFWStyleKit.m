//
//  BFWStyleKit.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWStyleKit.h"
#import "NSObject+BFWStyleKit.h"
#import "UIColor+BFW.h"
#import "NSString+BFW.h"
#import "NSDictionary+BFW.h"
#import "BFWStyleKitDrawing.h"

@interface BFWStyleKit ()

@property (nonatomic, strong) NSDictionary *returnValueForMethodDict;

@end

@implementation BFWStyleKit

#pragma mark - constants

static NSString * const drawPrefix = @"draw";
static NSString * const styleKitSuffix = @"StyleKit";
static NSString * const styleKitByPrefixKey = @"styleKitByPrefix";

#pragma mark - class methods

+ (NSDictionary *)styleKits
{
    static NSDictionary *styleKits = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary * mutableStyleKits = [[NSMutableDictionary alloc] init];
        for (Class class in [NSObject subclassesOf:[NSObject class]]) {
            NSString *className = NSStringFromClass(class);
            if ([className hasSuffix:styleKitSuffix] && class != self) {
                // TODO: implement a more robust filter than suffix when PaintCode offers it
                BFWStyleKit *styleKit = [[BFWStyleKit alloc] init];
                styleKit.name = className;
                styleKit.paintCodeClass = class;
                mutableStyleKits[className] = styleKit;
            }
        }
        styleKits = [mutableStyleKits copy];
    });
    return styleKits;
}

+ (instancetype)styleKitForName:(NSString *)name {
    return self.styleKits[name];
}

+ (BFWStyleKitDrawing *)drawingForStyleKitName:(NSString *)styleKitName
                                   drawingName:(NSString *)drawingName
{
    BFWStyleKit *styleKit = [self styleKitForName:styleKitName];
    BFWStyleKitDrawing *drawing = [styleKit drawingForName:drawingName];
    return drawing;
}

#pragma mark - accessors

- (NSDictionary *)returnValueForMethodDict
{
    if (!_returnValueForMethodDict) {
        _returnValueForMethodDict = [self.paintCodeClass returnValueForMethodDict];
    }
    return _returnValueForMethodDict;
}

- (NSDictionary *)colors
{
    if (!_colors) {
        NSMutableDictionary *colorsDict = [[NSMutableDictionary alloc] init];
        NSDictionary *methodValueDict = self.returnValueForMethodDict;
        for (NSString *methodName in methodValueDict) {
            id returnValue = methodValueDict[methodName];
            if ([returnValue isKindOfClass:[UIColor class]]) {
                // TODO: filter out non color methods
                colorsDict[methodName] = returnValue;
            }
        }
        _colors = [colorsDict copy];
    }
    return _colors;
}

- (NSDictionary *)drawings
{
    if (!_drawings) {
        NSMutableDictionary *drawingsDict = [[NSMutableDictionary alloc] init];
        NSDictionary *methodValueDict = self.returnValueForMethodDict;
        for (NSString *methodName in methodValueDict) {
            id returnValue = methodValueDict[methodName];
            if ([returnValue isEqual:[NSNull null]] && [methodName hasPrefix:drawPrefix]) {
                NSArray *methodNameComponents = [methodName methodNameComponents];
                if (methodNameComponents.count) {
                    NSString *name = [[methodNameComponents.firstObject substringFromIndex:drawPrefix.length] lowercaseFirstCharacter];
                    BFWStyleKitDrawing *drawing = [[BFWStyleKitDrawing alloc] init];
                    drawing.methodName = methodName;
                    drawing.name = name;
                    drawing.styleKit = self;
                    if (methodNameComponents.count > 1) {
                        drawing.methodParameters = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
                    }
                    drawingsDict[name] = drawing;
                }
            }
        }
        _drawings = [drawingsDict copy];
    }
    return _drawings;
}

- (NSBundle *)bundle
{
#if TARGET_INTERFACE_BUILDER // rendering in storyboard using IBDesignable
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
    NSBundle *bundle = [NSBundle mainBundle];
#endif
    return bundle;
}

- (NSDictionary *)parameterDict
{
    if (!_parameterDict) {
        NSString *path = [[self bundle] pathForResource:self.name ofType:@"plist"];
        NSMutableDictionary *parameterDict = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
        //TODO: move filtering to another class with references to consts for keys
        for (NSString *key in @[@"sizes", @"sizesByPrefix", @"derived"]) {
            NSDictionary *dictionary = parameterDict[key];
            if (dictionary) {
                NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
                for (NSString *oldKey in dictionary) {
                    NSString *newKey = oldKey.lowercaseWords;
                    mutableDict[newKey] = dictionary[oldKey];
                }
                parameterDict[key] = [mutableDict copy];
            }
        }
        _parameterDict = [parameterDict copy];
    }
    return _parameterDict;
}

#pragma mark - instance methods

- (UIColor *)colorForName:(NSString *)colorName
{
    UIColor *color = [self.colors objectForWordsKey:colorName];
    if (!color) {
        DLog(@"failed to find color name: %@", colorName);
    }
    return color;
}

- (BFWStyleKitDrawing *)drawingForName:(NSString *)drawingName
{
    BFWStyleKit *styleKit;
    NSString *redirectStyleKitName = [self.parameterDict[styleKitByPrefixKey] objectForLongestPrefixKeyMatchingWordsInString:drawingName];
    if (redirectStyleKitName) {
        styleKit = [[self class] styleKitForName:redirectStyleKitName];
    }
    else {
        styleKit = self;
    }
    BFWStyleKitDrawing *drawing = [styleKit.drawings objectForWordsKey:drawingName];
    if (!drawing) {
        DLog(@"failed to find drawing name: %@", drawingName);
    }
    return drawing;
}

#pragma mark - Android accessors

- (NSString *)colorsXmlString
{
    NSString *colorsXmlString = nil;
    if (self.colors.count) {
        NSMutableArray *components = [[NSMutableArray alloc] init];
        [components addObject:@"<!--Warning: Do not add any color to this file as it is generated by PaintCode and BFWDrawView-->"];
        [components addObject:@"<resources>"];
        NSArray *colorNames = [self.colors.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *colorName in colorNames) {
            UIColor *color = self.colors[colorName];
            NSString *colorHex = [color hexString];
            NSString *wordsString = [colorName camelCaseToWords];
            NSString *underscoreName = [wordsString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            NSString *androidColorName = underscoreName.lowercaseString;
            NSString *colorString = [NSString stringWithFormat:@"    <color name=\"%@\">#%@</color>", androidColorName, colorHex];
            [components addObject:colorString];
        }
        [components addObject:@"</resources>"];
        colorsXmlString = [components componentsJoinedByString:@"\n"];
    }
    return colorsXmlString;
}

@end
