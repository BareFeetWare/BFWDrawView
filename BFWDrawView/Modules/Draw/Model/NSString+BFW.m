//
//  NSString+BFW.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
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

- (NSString *)camelToWords
{
    NSMutableString *wordString = [[NSMutableString alloc] init];
    NSString *previousChar = nil;
    for (NSUInteger charN = 0; charN < self.length; charN++) {
        NSString *thisChar = [self substringWithRange:NSMakeRange(charN, 1)];
        NSString *nextChar = charN + 1 < self.length ? [self substringWithRange:NSMakeRange(charN + 1, 1)] : nil;
        if (charN > 0 && [thisChar isUppercase] && (![previousChar isUppercase] || (nextChar && ![nextChar isUppercase]))) {
            [wordString appendString:@" "];
        }
        [wordString appendString:thisChar];
        previousChar = thisChar;
    }
    return [NSString stringWithString:wordString];
}

- (NSString *)wordsToCamel
{
    NSMutableArray *camelWords = [[NSMutableArray alloc] init];
    NSArray *words = [self componentsSeparatedByString:@" "];
    for (NSString *word in words) {
        if (word.length) {
            [camelWords addObject:[word uppercaseFirstCharacter]];
        }
    }
    if (camelWords.count) {
        camelWords[0] = [camelWords[0] lowercaseFirstCharacter];
    }
    return [camelWords copy];
}

@end
