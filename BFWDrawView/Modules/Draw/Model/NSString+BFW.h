//
//  NSString+BFW.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BFW)

- (NSString *)uppercaseFirstCharacter; // only uppercase first character in string
- (NSString *)lowercaseFirstCharacter; // only lowercase first character in string
- (NSString *)androidFileName;

@end
