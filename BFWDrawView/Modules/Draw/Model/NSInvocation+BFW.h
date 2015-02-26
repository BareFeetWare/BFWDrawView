//
//  NSInvocation+BFW.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (BFW)

+ (NSInvocation *)invocationForClass:(Class)aClass
                            selector:(SEL)selector
                    argumentPointers:(NSArray *)argumentPointers;

@end
