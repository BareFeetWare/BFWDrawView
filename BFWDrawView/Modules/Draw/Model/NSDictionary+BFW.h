//
//  NSDictionary+BFW.h
//
//  Created by Tom Brodhurst-Hill on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BFW)

- (id)objectForLongestPrefixKeyMatchingWordsInString:(NSString *)inString;
- (id)objectForWordsKey:(NSString *)wordsKey;

@end
