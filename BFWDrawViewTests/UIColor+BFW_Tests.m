//
//  UIColor+BFW_Tests.m
//  BFWDrawView
//
//  Created by Tom Jowett on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "UIColor+BFW.h"

@interface UIColor_BFW_Tests : XCTestCase

@end

@implementation UIColor_BFW_Tests

- (void)testWhite {
    UIColor *white = [UIColor whiteColor];
    NSString *whiteHexString = [white cssHexString];
    XCTAssertEqualObjects(whiteHexString, @"ffffff");
}

- (void)testRed {
    UIColor *red = [UIColor redColor];
    NSString *redHexString = [red cssHexString];
    XCTAssertEqualObjects(redHexString, @"ff0000");
}

@end
