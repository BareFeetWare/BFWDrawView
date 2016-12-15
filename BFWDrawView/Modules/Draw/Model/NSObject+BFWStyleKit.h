//
//  NSObject+BFWStyleKit.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (BFWStyleKit)

#pragma mark - Introspection for NSObject subclasses

+ (NSArray * _Nonnull)classMethodNames;
+ (id _Nullable)returnValueForClassMethodName:(NSString * _Nonnull)methodName;
+ (NSDictionary * _Nonnull)returnValueForClassMethodNameDict;
+ (NSArray * _Nonnull)subclassesOf:(Class _Nonnull)parentClass;

@end
