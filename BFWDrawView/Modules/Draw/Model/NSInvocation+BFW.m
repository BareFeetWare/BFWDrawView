//
//  NSInvocation+BFW.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "NSInvocation+BFW.h"

@implementation NSInvocation (BFW)

+ (NSInvocation *)invocationForClass:(Class)class
                            selector:(SEL)selector
{
    NSInvocation *invocation;
    if ([class respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:selector];
        [invocation setTarget:class];
    }
    return invocation;
}

@end
