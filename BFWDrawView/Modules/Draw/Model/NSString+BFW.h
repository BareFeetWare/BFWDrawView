//
//  NSString+BFW.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import <Foundation/Foundation.h>

@interface NSString (BFW)

- (NSString *)uppercaseFirstCharacter; // only uppercase first character in string
- (NSString *)lowercaseFirstCharacter; // only lowercase first character in string
- (NSString *)camelCaseToWords; // convert camelCase to separate words
- (NSString *)wordsToPaintCodeCase; // convert separate words to the case that PaintCode uses for methods
- (NSString *)lowercaseWords;
- (NSString *)longestWordsMatchInPrefixArray:(NSArray *)prefixArray;

@end
