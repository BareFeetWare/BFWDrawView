//
//  NSString+BFW.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "NSString+BFW.h"

@implementation NSString (BFW)

- (NSString *)uppercaseFirstCharacter // only uppercase first character in string
{
    NSString *uppercaseFirstString = [[self substringToIndex:1] uppercaseString];
    uppercaseFirstString = [uppercaseFirstString stringByAppendingString:[self substringFromIndex:1]];
    return uppercaseFirstString;
}

- (NSString *)lowercaseFirstCharacter // only lowercase first character in string
{
    NSString *lowercaseFirstString = [[self substringToIndex:1] lowercaseString];
    lowercaseFirstString = [lowercaseFirstString stringByAppendingString:[self substringFromIndex:1]];
    return lowercaseFirstString;
}

- (BOOL)isUppercase
{
    return [self isEqualToString:self.uppercaseString];
}

- (NSString *)camelCaseToWords
{
    NSMutableString *wordString = [[NSMutableString alloc] init];
    NSString *previousChar = nil;
    for (NSUInteger charN = 0; charN < self.length; charN++) {
        NSString *thisChar = [self substringWithRange:NSMakeRange(charN, 1)];
        NSString *nextChar = charN + 1 < self.length ? [self substringWithRange:NSMakeRange(charN + 1, 1)] : nil;
        if (charN > 0 && ![previousChar isEqualToString:@" "] && ![thisChar isEqualToString:@" "] && [thisChar isUppercase] && (![previousChar isUppercase] || (nextChar && ![nextChar isUppercase]))) {
            [wordString appendString:@" "];
        }
        [wordString appendString:thisChar];
        previousChar = thisChar;
    }
    return [NSString stringWithString:wordString];
}

- (NSString *)wordsToPaintCodeCase
{
    NSMutableArray *casedWords = [[NSMutableArray alloc] init];
    NSArray *words = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *word in words) {
        if (word.length) {
            [casedWords addObject:[word uppercaseFirstCharacter]];
        }
    }
    return [casedWords componentsJoinedByString:@""];
}

- (NSString *)lowercaseWords
{
    return [self camelCaseToWords].lowercaseString;
}

- (NSString *)longestWordsMatchInPrefixArray:(NSArray *)prefixArray
{
    NSArray *sortedItems = [prefixArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        // sort from longest to shortest so more specific (longer) match is found first
        return obj1.length > obj2.length ? NSOrderedAscending : NSOrderedDescending;
    }];
    NSString *matchingPrefix = nil;
    NSString *lowercaseWords = [self lowercaseWords];
    for (NSString *prefix in sortedItems) {
        if ([lowercaseWords hasPrefix:[prefix lowercaseWords]]) {
            matchingPrefix = prefix;
            break;
        }
    }
    return matchingPrefix;
}

- (NSString *)wordsMatchingWordsArray:(NSArray *)wordsArray
{
    NSString *foundString = nil;
    NSString *searchWords = [self lowercaseWords];
    for (NSString *words in wordsArray) {
        if ([searchWords isEqualToString:[words lowercaseWords]]) {
            foundString = words;
            break;
        }
    }
    return foundString;
}

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
