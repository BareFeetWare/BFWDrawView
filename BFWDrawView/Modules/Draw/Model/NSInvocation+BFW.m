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
                    argumentPointers:(NSArray *)argumentPointers
{
    NSInvocation *invocation;
    if ([class respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:selector];
        [invocation setTarget:class];
        for (NSUInteger argumentN = 0; argumentN < argumentPointers.count; argumentN++) {
            NSValue *argumentAddress = argumentPointers[argumentN];
            [invocation setArgument:argumentAddress.pointerValue atIndex:argumentN + 2];
        }
    }
    return invocation;
}

@end
