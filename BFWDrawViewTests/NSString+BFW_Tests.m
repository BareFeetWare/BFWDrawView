//
//  NSString+BFW_Tests.m
//  NSString+BFW_Tests
//
//  Created by Tom Brodhurst-Hill on 1/02/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSString+BFW.h"

@interface NSString_BFW_Tests : XCTestCase

@end

@implementation NSString_BFW_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlist {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"+" withString:@"_"];
    NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:className ofType:@"plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *selectorExpectationDict = plistDict[@"selectorExpectations"];
    XCTAssert(selectorExpectationDict, @"Cannot get selectorExpectations from plist");
    for (NSString *selectorName in selectorExpectationDict) {
        NSArray *expectations = selectorExpectationDict[selectorName];
        for (NSDictionary *expectation in expectations) {
            id selfValue = expectation[@"self"];
            SEL selector = NSSelectorFromString(selectorName);
            BOOL responds = [selfValue respondsToSelector:selector];
            XCTAssert(responds, @"%@ does not respond to %@", selfValue, selectorName);
            if (responds) {
                NSMethodSignature *methodSignature = [selfValue methodSignatureForSelector:selector];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                [invocation setSelector:selector];
                [invocation setTarget:selfValue];
                [invocation invoke];
                id __unsafe_unretained tempReturnValue;
                [invocation getReturnValue:&tempReturnValue];
                id testReturnValue = tempReturnValue;
                id expectReturnValue = expectation[@"return"];
                NSLog(@"testing [%@ %@] isEqualTo: %@", selfValue, selectorName, expectReturnValue);
                XCTAssertEqualObjects(expectReturnValue, testReturnValue, @"Pass %@", selectorName);
            }
        }
    }
}

@end
