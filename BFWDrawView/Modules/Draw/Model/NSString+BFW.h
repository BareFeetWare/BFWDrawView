//
//  NSString+BFW.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import <Foundation/Foundation.h>

@interface NSString (BFW)

@property (nonatomic, readonly, nullable) NSArray *methodNameComponents;
@property (nonatomic, readonly, nonnull) NSString *uppercaseFirstCharacter; // only uppercase first character in string
@property (nonatomic, readonly, nonnull) NSString *lowercaseFirstCharacter; // only lowercase first character in string
@property (nonatomic, readonly, nonnull) NSString *camelCaseToWords; // convert camelCase to separate words
@property (nonatomic, readonly, nonnull) NSString *wordsToPaintCodeCase; // convert separate words to the case that PaintCode uses for methods
@property (nonatomic, readonly, nonnull) NSString *lowercaseWords;

- (NSString * _Nonnull)longestWordsMatchInPrefixArray:(NSArray * _Nonnull)prefixArray;
- (NSString * _Nonnull)wordsMatchingWordsArray:(NSArray * _Nonnull)wordsArray;

@end
