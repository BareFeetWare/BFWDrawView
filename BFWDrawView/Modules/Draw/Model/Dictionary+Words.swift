//
//  NSDictionary+BFW.m
//
//  Created by Tom Brodhurst-Hill on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "NSDictionary+BFW.h"
#import "NSString+BFW.h"

@implementation NSDictionary (BFW)

- (id)objectForLongestPrefixKeyMatchingWordsInString:(NSString *)inString
{
    id object = nil;
    NSString *prefix = [inString longestWordsMatchInPrefixArray:self.allKeys];
    if (prefix) {
        object = self[prefix];
    }
    return object;
}

- (id)objectForWordsKey:(NSString *)wordsKey
{
    id object = self[wordsKey];
    if (!object) {
        NSString *searchKey = [wordsKey lowercaseWords];
        for (NSString *key in self.allKeys) {
            if ([searchKey isEqualToString:[key lowercaseWords]]) {
                object = self[key];
                break;
            }
        }
    }
    return object;
}

@end
