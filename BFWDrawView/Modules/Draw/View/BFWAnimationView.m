//
//  BFWAnimationView.m
//
//  Created by Tom Brodhurst-Hill on 15/01/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Permission granted for unlimited use, without liability.
//  with acknowledgement to BareFeetWare.
//

#import "BFWAnimationView.h"

static CGFloat const fps = 30.0;
static CGFloat const duration = 3.0;

@interface BFWAnimationView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startDate;

@end

@implementation BFWAnimationView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / fps
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
    _startDate = [NSDate date];
}

- (void)tick:(NSTimer*)timer
{
    // Get current time (in seconds)
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startDate];
    
    // Get the fractional part of the current time (ensures 0..1 interval)
    self.animation = (elapsed / duration) - floorf(elapsed / duration);
    [self setNeedsDisplay];
}

- (NSInvocation *)drawInvocation
{
    // TODO: cache invocation but allow changing animation value
    NSInvocation *invocation;
    CGRect frame = self.drawFrame;
    NSValue *framePointer = [NSValue valueWithPointer:&frame];
    CGFloat animation = self.animation;
    NSValue *animationPointer = [NSValue valueWithPointer:&animation];
    NSString *selectorString = [NSString stringWithFormat:@"draw%@WithFrame:animation:", [self.name capitalizedFirstString]];
    SEL selector = NSSelectorFromString(selectorString);
    if ([self.styleKitClass respondsToSelector:selector]) {
        invocation = [self drawInvocationForSelectorString:selectorString argumentPointers:@[framePointer, animationPointer]];
    }
    else {
        NSString *selectorString = [NSString stringWithFormat:@"draw%@WithFrame:fillColor:animation:", [self.name capitalizedFirstString]];
        SEL selector = NSSelectorFromString(selectorString);
        if ([self.styleKitClass respondsToSelector:selector]) {
            UIColor *fillColor = self.fillColor;
            NSValue *fillColorPointer = [NSValue valueWithPointer:&fillColor];
            invocation = [self drawInvocationForSelectorString:selectorString argumentPointers:@[framePointer, fillColorPointer, animationPointer]];
        }
        else {
            NSLog(@"**** error: No animation method for name: %@", self.name);
        }
    }
    return invocation;
}

@end
