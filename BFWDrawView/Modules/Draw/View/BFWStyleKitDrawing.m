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

@property (nonatomic, assign, readwrite) CGSize drawnSize;
@property (nonatomic, assign) BOOL didSetDrawnSize;
@property (nonatomic, copy) NSString *lookupName;

@end

static NSString * const sizesKey = @"sizes";
static NSString * const sizesByPrefixKey = @"sizesByPrefix";

@implementation BFWStyleKitDrawing

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
