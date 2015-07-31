//
//  NSArray+BFW.m
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "NSArray+BFW.h"

@implementation NSArray (BFW)

- (NSArray *)arrayOfStringsSortedCaseInsensitive
{
    NSArray *sortedArray = [self sortedArrayUsingComparator:^NSComparisonResult(NSString *string1, NSString *string2) {
        return [string1 compare:string2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

@end
