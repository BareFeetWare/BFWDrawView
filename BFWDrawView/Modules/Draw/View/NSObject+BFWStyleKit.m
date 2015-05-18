//
//  NSObject+BFWStyleKit.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "NSObject+BFWStyleKit.h"
#import "UIColor+BFW.h"
#import "NSInvocation+BFW.h"
#import "NSString+BFW.h"
#import <objc/runtime.h>

@implementation NSString (BFWStyleKit)

- (NSArray *)methodNameComponents
{
    static NSString * const withString = @"With";
    
    NSArray *parameters = nil;
    if ([self hasSuffix:@":"]) {
        NSArray *parameterComponents = [self componentsSeparatedByString:@":"];
        NSArray *withComponents = [parameterComponents.firstObject componentsSeparatedByString:withString];
        if (withComponents.count) {
            NSString *methodBaseName = [[withComponents subarrayWithRange:NSMakeRange(0, withComponents.count - 1)] componentsJoinedByString:withString];
            NSString *firstParameter = [withComponents.lastObject lowercaseFirstCharacter];
            NSMutableArray *mutableParameters = [[NSMutableArray alloc] init];
            [mutableParameters addObject:methodBaseName];
            [mutableParameters addObject:firstParameter];
            [mutableParameters addObjectsFromArray:[parameterComponents subarrayWithRange:NSMakeRange(1, parameterComponents.count - 2)]];
            parameters = [mutableParameters copy];
        }
    }
    else {
        parameters = @[self];
    }
    return parameters;
}

@end

@implementation NSObject (BFWStyleKit)

#pragma mark - Introspection

+ (NSArray *)methodNames
{
    NSMutableArray *methodNames = [[NSMutableArray alloc] init];
    int unsigned methodCount;
    Method *methods = class_copyMethodList(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]), &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        [methodNames addObject:methodName];
    }
    free(methods);
    return [methodNames copy];
}

+ (NSDictionary *)classMethodValueDict
{
    static NSString * const classType = @"@";
    static NSString * const voidType = @"v";
    
    NSMutableDictionary *methodDict = [[NSMutableDictionary alloc] init];
    int unsigned methodCount;
    Method *methods = class_copyMethodList(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]), &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        char *returnType = method_copyReturnType(method);
        NSString *typeString = [NSString stringWithUTF8String:returnType];
        id returnValue;
        if ([typeString isEqualToString:classType]) {
            // Danger: calling method may have side effects
            NSInvocation *invocation = [NSInvocation invocationForClass:[self class]
                                                               selector:NSSelectorFromString(methodName) // TODO: more direct way
                                                       argumentPointers:nil];
            [invocation invoke];
            id __unsafe_unretained tempReturnValue;
            [invocation getReturnValue:&tempReturnValue];
            returnValue = tempReturnValue;
        }
        else if ([typeString isEqualToString:voidType]) {
            returnValue= [NSNull null];
        }
        else {
            DLog(@"**** unexpected returnType = %s", returnType);
        }
        if (returnValue) {
            methodDict[methodName] = returnValue;
        }
        free(returnType);
    }
    free(methods);
    return [methodDict copy];
}

+ (NSDictionary *)methodParametersDict
{
    NSMutableDictionary *methodParametersDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        NSArray *methodNameComponents = [methodName methodNameComponents];
        if (methodNameComponents.count) {
            methodParametersDict[methodName] = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
        }
    }
    return [methodParametersDict copy];
}

#pragma mark - Introspection for StyleKit classes produced by PaintCode

+ (NSBundle *)bundle
{
#if TARGET_INTERFACE_BUILDER // rendering in storyboard using IBDesignable
    NSBundle *bundle = [NSBundle bundleForClass:self];
#else
    NSBundle *bundle = [NSBundle mainBundle];
#endif
    return bundle;
}

+ (NSDictionary *)parameterDict
{
    NSString *styleKit = NSStringFromClass([self class]);
    NSString *path = [[self bundle] pathForResource:styleKit ofType:@"plist"];
    NSDictionary *parameterDict = [NSDictionary dictionaryWithContentsOfFile:path];
    return parameterDict;
}

+ (NSDictionary *)colorDict
{
    NSMutableDictionary *colorDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        id returnValue = methodValueDict[methodName];
        if ([returnValue isKindOfClass:[UIColor class]]) {
            colorDict[methodName] = returnValue;
        }
    }
    return [colorDict copy];
}

+ (UIColor *)colorWithName:(NSString *)colorName
{
    UIColor *color;
    SEL selector = NSSelectorFromString([[colorName wordsToPaintCodeCase] lowercaseFirstCharacter]);
    NSInvocation *invocation = [NSInvocation invocationForClass:self
                                                       selector:selector
                                               argumentPointers:nil];
    [invocation invoke];
    id __unsafe_unretained tempReturnValue;
    [invocation getReturnValue:&tempReturnValue];
    UIColor *foundColor = (UIColor *)tempReturnValue;
    if ([foundColor isKindOfClass:[UIColor class]]) {
        color = foundColor;
    }
    else {
        DLog(@"failed to find color name: %@", colorName);
    }
    return color;
}

+ (NSString *)colorsXmlString
{
    NSString *colorsXmlString = nil;
    NSDictionary *colorDict = [self colorDict];
    if (colorDict.count) {
        NSMutableArray *components = [[NSMutableArray alloc] init];
        [components addObject:@"<!--Warning: Do not add any color to this file as it is generated by PaintCode and BFWDrawView-->"];
        [components addObject:@"<resources>"];
        NSArray *colorNames = [colorDict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *colorName in colorNames) {
            UIColor *color = colorDict[colorName];
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

+ (NSDictionary *)drawParameterDict
{
    static NSString * const drawPrefix = @"draw";
    NSMutableDictionary *methodParametersDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        id returnValue = methodValueDict[methodName];
        if ([returnValue isKindOfClass:[NSNull class]] && [methodName hasPrefix:drawPrefix]) {
            NSArray *methodNameComponents = [methodName methodNameComponents];
            NSString *drawName = [[methodNameComponents.firstObject substringFromIndex:drawPrefix.length] lowercaseFirstCharacter];
            if (methodNameComponents.count) {
                methodParametersDict[drawName] = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
            }
        }
    }
    return [methodParametersDict copy];
}

@end
