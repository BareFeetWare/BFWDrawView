//
//  BFWDrawView.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDLog.h"
#import "BFWDrawView.h"
#import "UIImage+BFW.h"
#import "NSInvocation+BFW.h"
#import "NSString+BFW.h"
#import "NSDictionary+BFW.h"
#import "NSObject+BFWStyleKit.h" // for DLog
#import <QuartzCore/QuartzCore.h>
#import "BFWStyleKit.h"
#import "BFWStyleKitDrawing.h"

@interface UIView (BFW)

- (void)copyPropertiesFromView:(BFWDrawView *)view;

@end

@interface BFWDrawView ()

@property (nonatomic, strong) NSInvocation *drawInvocation;
@property (nonatomic, readonly) Class styleKitClass;
@property (nonatomic, assign) BOOL didCheckCanDraw;
@property (nonatomic, readonly) CGSize drawInFrameSize;
@property (nonatomic, assign) CGRect invokedDrawFrame;
@property (nonatomic, strong) UIColor *invokedTintColor; // retains reference to tintColor so NSInvocation doesn't crash if the "darken colors" is enabled in System Preferences in iOS 9
@property (nonatomic, assign) CGFloat invokedAnimation;

@end

@implementation BFWDrawView

#pragma mark - accessors

- (Class)styleKitClass
{
    return self.drawing.styleKit.paintCodeClass;
}

#pragma mark - drawing

- (void)setNeedsDraw {
    _drawInvocation = nil;
    [self setNeedsDisplay];
}

- (NSArray *)parameters {
    return self.drawing.methodParameters;
}

- (CGRect)drawFrame {
    // implemented in DrawingView subclass.
    return CGRectZero;
}

- (BOOL)updateArgumentForParameter:(NSString *)parameter
{
    BOOL success = NO;
    NSUInteger index = [self.parameters indexOfObject:parameter];
    if (index != NSNotFound) {
        void *argument = [self argumentForParameter:parameter];
        if (argument) {
            [_drawInvocation setArgument:argument
                                 atIndex:index + 2]; // 0 and 1 are used by NSInvocation for self and _cmd
            success = YES;
        }
    }
    return success;
}

- (void *)argumentForParameter:(NSString *)parameter
{
    void *argument = nil;
    if ([parameter isEqualToString:@"frame"]) {
        self.invokedDrawFrame = [self drawFrame];
        argument = &_invokedDrawFrame;
    }
    else if ([parameter isEqualToString:@"tintColor"]) {
        self.invokedTintColor = self.tintColor;
        argument = &_invokedTintColor;
    }
    else if ([parameter isEqualToString:@"animation"]) {
        self.invokedAnimation = [self animationBetweenStartAndEnd];
        argument = &_invokedAnimation;
    }

    return argument;
}

- (SEL)drawingSelector {
    return NSSelectorFromString(self.drawing.methodName);
}

- (NSInvocation *)drawInvocation
{
    if (!_drawInvocation) {
        SEL selector = self.drawingSelector;
        Class class = self.styleKitClass;
        if ([class respondsToSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            _drawInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [_drawInvocation setSelector:selector];
            [_drawInvocation setTarget:class];
            for (NSString *parameter in self.parameters) {
                BOOL success = [self updateArgumentForParameter:parameter];
                if (!success) {
                    _drawInvocation = nil;
                    BFWDLog(@"**** error: unexpected parameter: %@", parameter);
                    break;
                }
            }
        }
    }
    return _drawInvocation;
}

- (BOOL)canDraw
{
    self.didCheckCanDraw = YES;
    return self.drawInvocation ? YES : NO;
}

- (void)drawRect:(CGRect)rect
{
    [self.drawInvocation invoke];
}

#pragma mark - protocols for UIView+BFW

- (void)copyPropertiesFromView:(BFWDrawView *)view
{
    [super copyPropertiesFromView:view];
}

@end
