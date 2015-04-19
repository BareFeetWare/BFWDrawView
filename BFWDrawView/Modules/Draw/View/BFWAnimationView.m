//
//  BFWAnimationView.m
//
//  Created by Tom Brodhurst-Hill on 15/01/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWAnimationView.h"
#import "NSString+BFW.h"
#import "NSInvocation+BFW.h"

static CGFloat const fps = 30.0;

@interface BFWAnimationView ()

@property (nonatomic, weak) NSTimer *timer; // NSRunLoop holds a strong reference
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *pausedDate;
@property (nonatomic, assign) NSTimeInterval pausedTimeInterval;
@property (nonatomic, assign) BOOL finished;

@end

@implementation BFWAnimationView

#pragma mark - init

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
    _duration = 3.0; // default seconds
}

#pragma mark - accessors

- (BOOL)paused
{
    return self.pausedDate != nil;
}

- (void)setPaused:(BOOL)paused
{
    if (self.paused != paused) {
        if (paused) {
            self.pausedDate = [NSDate date];
            [self.timer invalidate];
            self.timer = nil;
        }
        else {
            if (self.startDate) {
                NSTimeInterval morePausedTimeInterval = [[NSDate date] timeIntervalSinceDate:self.pausedDate];
                self.pausedTimeInterval += morePausedTimeInterval;
            }
            self.pausedDate = nil;
            [self startTimerIfNeeded];
        }
    }
}

- (void)setAnimation:(CGFloat)animation
{
    if (_animation != animation) {
        _animation = animation;
        [self setNeedsDisplay];
    }
}

#pragma mark - animation

- (void)restart
{
    self.pausedDate = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.finished = NO;
    self.startDate = nil;
    [self startTimerIfNeeded];
}

- (void)startTimerIfNeeded
{
    if (!self.timer && !self.paused && !self.finished) {
        if (!self.startDate) {
            self.startDate = [NSDate date];
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / fps
                                                      target:self
                                                    selector:@selector(tick:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)tick:(NSTimer*)timer
{
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startDate] - self.pausedTimeInterval;
    
    CGFloat complete = elapsed / self.duration;
    self.finished = (self.cycles && complete > self.cycles);
    if (self.paused || self.finished) {
        [self.timer invalidate];
        self.timer = nil;
        if (self.finished) {
            self.animation = 1.0; // ensure it draws final frame
        }
    }
    else {
        // Get the fractional part of the current time (ensures 0..1 interval)
        self.animation = complete - floorf(complete);
    }
}

#pragma mark - BFWDrawView

- (void)drawRect:(CGRect)rect
{
    [self startTimerIfNeeded];
    [super drawRect:rect];
}

- (CGFloat)animationBetweenStartAndEnd
{
    CGFloat animation = self.animation;
    if (self.start || self.end) {
        animation = self.start + self.animation * (self.end - self.start);
    }
    return animation;
}

- (NSInvocation *)drawInvocation
{
    // TODO: cache invocation but allow changing animation value
    NSInvocation *invocation;
    CGRect frame = self.drawFrame;
    NSValue *framePointer = [NSValue valueWithPointer:&frame];
    CGFloat animation = [self animationBetweenStartAndEnd];
    NSValue *animationPointer = [NSValue valueWithPointer:&animation];
    NSString *drawFrameSelectorString = [self drawFrameSelectorString];
    NSString *selectorString = [drawFrameSelectorString stringByAppendingString:@"animation:"];
    SEL selector = NSSelectorFromString(selectorString);
    if ([self.styleKitClass respondsToSelector:selector]) {
        invocation = [NSInvocation invocationForClass:self.styleKitClass
                                             selector:selector
                                     argumentPointers:@[framePointer, animationPointer]];
    }
    else {
        NSString *selectorString = [drawFrameSelectorString stringByAppendingString:@"tintColor:animation:"];
        SEL selector = NSSelectorFromString(selectorString);
        if ([self.styleKitClass respondsToSelector:selector]) {
            UIColor *tintColor = self.tintColor;
            NSValue *tintColorPointer = [NSValue valueWithPointer:&tintColor];
            invocation = [NSInvocation invocationForClass:self.styleKitClass
                                                 selector:selector
                                         argumentPointers:@[framePointer, tintColorPointer, animationPointer]];
        }
        else {
            invocation = [super drawInvocation];
        }
    }
    return invocation;
}

@end
