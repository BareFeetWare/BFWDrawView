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

@property (nonatomic, strong) NSDictionary *returnValueForClassMethodNameDict; // @{NSString : NSObject}
@property (nonatomic, strong) NSMutableDictionary *colorForNameDict; // @{NSString : UIColor}
@property (nonatomic, strong) NSMutableDictionary *drawingForNameDict; // @{NSString : BFWStyleKitDrawing}

@end

@implementation BFWStyleKit

#pragma mark - constants

static NSString * const styleKitSuffix = @"StyleKit";
static NSString * const styleKitByPrefixKey = @"styleKitByPrefix";

#pragma mark - class methods

+ (NSMutableDictionary *)styleKitForNameDict
{
    static NSMutableDictionary *styleKitForNameDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        styleKitForNameDict = [[NSMutableDictionary alloc] init];
    });
    return styleKitForNameDict;
}

+ (NSArray *)styleKitNames
{
    static NSArray *styleKitNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray* mutableStyleKitNames = [[NSMutableArray alloc] init];
        for (Class class in [NSObject subclassesOf:[NSObject class]]) {
            NSString *className = NSStringFromClass(class);
            if ([className hasSuffix:styleKitSuffix] && class != self) {
                // TODO: implement a more robust filter than suffix when PaintCode offers it
                [mutableStyleKitNames addObject:className];
            }
        }
        styleKitNames = [mutableStyleKitNames copy];
    });
    return styleKitNames;
}

+ (instancetype)styleKitForName:(NSString *)name
{
    BFWStyleKit* styleKit = [self styleKitForNameDict][name];
    if (!styleKit) {
        styleKit = [[BFWStyleKit alloc] init];
        styleKit.name = name;
        styleKit.paintCodeClass = NSClassFromString(name);
        [self styleKitForNameDict][name] = styleKit;
    }
    return styleKit;
}

+ (BFWStyleKitDrawing *)drawingForStyleKitName:(NSString *)styleKitName
                                   drawingName:(NSString *)drawingName
{
    BFWStyleKit *styleKit = [self styleKitForName:styleKitName];
    BFWStyleKitDrawing *drawing = [styleKit drawingForName:drawingName];
    return drawing;
}

#pragma mark - Class method names

- (NSArray *)classMethodNames
{
    if (!_classMethodNames) {
        _classMethodNames = [self.paintCodeClass classMethodNames];
    }
    return _classMethodNames;
}

#pragma mark - Full list methods

// Calling any of these methods is expensive, since it executes every method and caches the returnValue. Use only for discovery, eg showing a browser of all drawings.

- (NSDictionary *)returnValueForClassMethodNameDict
{
    if (!_returnValueForClassMethodNameDict) {
        DLog(@"**** warning: calling BFWStyleKit returnValueForClassMethodNameDict, which has a large up front caching hit for the app. Only call this if you want to browse the entire list of drawings and colors available from the styleKit");
        _returnValueForClassMethodNameDict = [self.paintCodeClass returnValueForClassMethodNameDict];
    }
    return _returnValueForClassMethodNameDict;
}

- (NSArray *)colorNames
{
    if (!_colorNames) {
        NSMutableDictionary *colorsDict = [[NSMutableDictionary alloc] init];
        NSDictionary *methodValueDict = self.returnValueForClassMethodNameDict;
        for (NSString *methodName in methodValueDict) {
            id returnValue = methodValueDict[methodName];
            if ([returnValue isKindOfClass:[UIColor class]]) {
                // TODO: filter out non color methods
                colorsDict[methodName] = returnValue;
            }
        }
        _colorForNameDict = [colorsDict copy];
        _colorNames = colorsDict.allKeys;
    }
    return _colorNames;
}

- (NSArray *)drawingNames
{
    if (!_drawingNames) {
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        NSDictionary *methodValueDict = [self returnValueForClassMethodNameDict];
        for (NSString *methodName in methodValueDict) {
            id returnValue = methodValueDict[methodName];
            if ([returnValue isEqual:[NSNull null]] && [methodName hasPrefix:drawPrefix]) {
                NSString *drawingName = [self drawingNameForMethodName:methodName];
                [mutableArray addObject:drawingName];
            }
        }
        _drawingNames = [mutableArray copy];
    }
    return _drawingNames;
}

#pragma mark - Use cache if already created

- (id)returnValueForClassMethodName:(NSString *)methodName
{
    id returnValue = nil;
    if (_returnValueForClassMethodNameDict) {
        returnValue = _returnValueForClassMethodNameDict[methodName];
    } else {
        returnValue = [self.paintCodeClass returnValueForClassMethodName:methodName];
    }
    return returnValue;
}

#pragma mark - Plist

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

#pragma mark - Colors

- (NSMutableDictionary *)colorForNameDict
{
    if (!_colorForNameDict) {
        _colorForNameDict = [[NSMutableDictionary alloc] init];
    }
    return _colorForNameDict;
}

- (UIColor *)colorForName:(NSString *)colorName
{
    UIColor *color = [self.colorForNameDict objectForWordsKey:colorName];
    if (!color) {
        NSString *methodName = [colorName wordsMatchingWordsArray:self.classMethodNames];
        id returnValue = [self returnValueForClassMethodName:methodName];
        if ([returnValue isKindOfClass:[UIColor class]]) {
            // TODO: filter out non color methods
            color = (UIColor *)returnValue;
            self.colorForNameDict[methodName] = color;
        } else {
            DLog(@"**** error: failed to find color for name: %@", colorName);
        }
    }
    return color;
}

#pragma mark - Drawings

- (NSMutableDictionary *)drawingForNameDict
{
    if (!_drawingForNameDict) {
        _drawingForNameDict = [[NSMutableDictionary alloc] init];
    }
    return _drawingForNameDict;
}

- (NSString *)drawingNameForMethodName:(NSString *)methodName
{
    NSString *drawingName = nil;
    NSArray *methodNameComponents = [methodName methodNameComponents];
    if (methodNameComponents.count) {
        drawingName = [[methodNameComponents.firstObject substringFromIndex:drawPrefix.length] lowercaseFirstCharacter];
    }
    return drawingName;
}

- (NSString *)classMethodNameForDrawingName:(NSString *)drawingName
{
    NSString *methodName = nil;
    NSString *drawingWords = [NSString stringWithFormat:@"%@ %@", drawPrefix, drawingName.lowercaseWords];
    for (NSString *searchMethodName in self.classMethodNames) {
        NSString *baseName = searchMethodName.methodNameComponents.firstObject;
        if ([baseName.lowercaseWords isEqualToString:drawingWords]) {
            methodName = searchMethodName;
            break;
        }
    }
    return methodName;
}

- (BFWStyleKitDrawing *)drawingForName:(NSString *)drawingName
{
    BFWStyleKitDrawing *drawing = nil;
    BFWStyleKit *styleKit;
    NSString *redirectStyleKitName = [self.parameterDict[styleKitByPrefixKey] objectForLongestPrefixKeyMatchingWordsInString:drawingName];
    if (redirectStyleKitName && ![redirectStyleKitName isEqualToString:self.name]) {
        styleKit = [[self class] styleKitForName:redirectStyleKitName];
        drawing = [styleKit drawingForName:drawingName];
    } else {
        NSString *drawingKey = drawingName.lowercaseWords;
        drawing = self.drawingForNameDict[drawingKey];
        if (!drawing) {
            if ([self classMethodNameForDrawingName:drawingName]) {
                drawing = [[BFWStyleKitDrawing alloc] initWithStyleKit:self
                                                                  name:drawingName];
                self.drawingForNameDict[drawingKey] = drawing;
            } else {
                DLog(@"failed to find drawing name: %@", drawingName);
            }
        }
    }
    return drawing;
}

#pragma mark - Android accessors

- (NSString *)colorsXmlString
{
    NSString *colorsXmlString = nil;
    NSArray* colorNames = [self.colorNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.colorNames.count) {
        NSMutableArray *components = [[NSMutableArray alloc] init];
        [components addObject:@"<!--Warning: Do not add any color to this file as it is generated by PaintCode and BFWDrawView-->"];
        [components addObject:@"<resources>"];
        for (NSString *colorName in colorNames) {
            UIColor *color = [self colorForName:colorName];
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
