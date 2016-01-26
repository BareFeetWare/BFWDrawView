//
//  BFWStyleKitDrawing.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWStyleKitDrawing.h"
#import "BFWStyleKit.h"
#import "NSDictionary+BFW.h"
#import "NSString+BFW.h"

@interface BFWStyleKitDrawing ()

@property (nonatomic, weak, readwrite) BFWStyleKit *styleKit;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSArray *methodParameters;
@property (nonatomic, copy, readwrite) NSString *methodName;
@property (nonatomic, assign, readwrite) CGSize drawnSize;
@property (nonatomic, assign) BOOL didSetDrawnSize;
@property (nonatomic, copy) NSString *lookupName;

@end

NSString * const drawPrefix = @"draw";
static NSString * const sizesKey = @"sizes";
static NSString * const sizesByPrefixKey = @"sizesByPrefix";

@implementation BFWStyleKitDrawing

#pragma mark - Init

- (instancetype)initWithStyleKit:(BFWStyleKit *)styleKit
                            name:(NSString *)name
{
    self = [super init];
    if (self) {
        _styleKit = styleKit;
        _name = name;
    }
    return self;
}

#pragma mark - Accessors

- (NSString *)methodName
{
    if (!_methodName) {
        _methodName = [self.styleKit classMethodNameForDrawingName:self.name];
    }
    return _methodName;
}

- (NSArray *)methodParameters
{
    if (!_methodParameters) {
        NSArray *methodNameComponents = [self.methodName methodNameComponents];
        if (methodNameComponents.count) {
            if (methodNameComponents.count > 1) {
                _methodParameters = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
            }
        }
    }
    return _methodParameters;
}

- (NSString *)lookupName
{
    if (!_lookupName) {
        _lookupName = self.name.lowercaseWords;
    }
    return _lookupName;
}

- (CGSize)drawnSize
{
    if (!self.didSetDrawnSize) {
        self.didSetDrawnSize = YES;
        NSDictionary *parameterDict = self.styleKit.parameterDict;
        NSString *sizeString = [parameterDict[sizesKey] objectForWordsKey:self.lookupName];
        if (!sizeString) {
            sizeString = [parameterDict[sizesByPrefixKey] objectForLongestPrefixKeyMatchingWordsInString:self.lookupName];
        }
        _drawnSize = sizeString ? CGSizeFromString(sizeString) : CGSizeZero;
    }
    return _drawnSize;
}

- (BOOL)hasDrawnSize
{
    return !CGSizeEqualToSize(self.drawnSize, CGSizeZero);
}

- (CGRect)intrinsicFrame
{
    return CGRectMake(0, 0, self.drawnSize.width, self.drawnSize.height);
}

@end
