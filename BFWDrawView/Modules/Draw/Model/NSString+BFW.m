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

@end
