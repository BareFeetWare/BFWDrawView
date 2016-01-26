//
//  NSObject+BFWStyleKit.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* Disable Debug logging for release builds */
#endif

@interface NSObject (BFWStyleKit)

#pragma mark - Introspection for NSObject subclasses

+ (NSArray *)classMethodNames;
+ (id)returnValueForClassMethodName:(NSString *)methodName;
+ (NSDictionary *)returnValueForClassMethodNameDict;
+ (NSArray *)subclassesOf:(Class)parentClass;

@end
