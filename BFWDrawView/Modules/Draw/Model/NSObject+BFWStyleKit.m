//
//  NSObject+BFWStyleKit.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWDLog.h"
#import "NSObject+BFWStyleKit.h"
#import "NSInvocation+BFW.h"
#import <objc/runtime.h>

@implementation NSObject (BFWStyleKit)

#pragma mark - Introspection

+ (NSArray *)classMethodNames
{
    NSMutableArray *methodNames = [[NSMutableArray alloc] init];
    int unsigned methodCount;
    Method *methods = class_copyMethodList(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]), &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        [methodNames addObject:methodName];
    }
    free(methods);
    return [methodNames copy];
}

+ (id)returnValueForClassMethodName:(NSString *)methodName
{
    static NSString * const classType = @"@";
    static NSString * const voidType = @"v";
    Class class = objc_getMetaClass([NSStringFromClass([self class]) UTF8String]);
    Method method = class_getClassMethod(class, NSSelectorFromString(methodName));
    char *returnType = method_copyReturnType(method);
    NSString *typeString = [NSString stringWithUTF8String:returnType];
    id returnValue = nil;
    if ([typeString isEqualToString:classType]) {
        // Danger: calling method may have side effects
        NSInvocation *invocation = [NSInvocation invocationForClass:[self class]
                                                           selector:NSSelectorFromString(methodName) // TODO: more direct way
                                    ];
        [invocation invoke];
        id __unsafe_unretained tempReturnValue;
        [invocation getReturnValue:&tempReturnValue];
        returnValue = tempReturnValue;
    }
    else if ([typeString isEqualToString:voidType]) {
        returnValue= [NSNull null];
    }
    else {
        BFWDLog(@"**** unexpected returnType = %s", returnType);
    }
    free(returnType);
    return returnValue;
}

+ (NSDictionary *)returnValueForClassMethodNameDict
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *methodName in [self classMethodNames]) {
        id returnValue = [self returnValueForClassMethodName:methodName];
        if (returnValue) {
            mutableDictionary[methodName] = returnValue;
        }
    }
    return [mutableDictionary copy];
}

@end
