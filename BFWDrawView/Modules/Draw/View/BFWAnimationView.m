//
//  BFWAnimationView.m
//
//  Created by Tom Brodhurst-Hill on 15/01/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWAnimationView.h"

static CGFloat const fps = 30.0;

@interface BFWAnimationView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *pausedDate;

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
    _startDate = [NSDate date];
    [self startTimer]; // TODO: move to after init
}

#pragma mark - accessors

- (void)setPaused:(BOOL)paused
{
    if (_paused != paused) {
        if (paused) {
            [self.timer invalidate];
            self.pausedDate = [NSDate date];
        }
        else {
            NSTimeInterval pausedTimeInterval = [self.pausedDate timeIntervalSinceDate:self.startDate];
            self.startDate = [self.startDate dateByAddingTimeInterval:pausedTimeInterval];
            [self startTimer];
        }
        _paused = paused;
    }
}

#pragma mark - animation

- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / fps
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)tick:(NSTimer*)timer
{
    // Get current time (in seconds)
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startDate];
    
    
    CGFloat complete = elapsed / self.duration;
    if (self.paused || (self.cycles && complete > self.cycles)) {
        [self.timer invalidate];
    }
    else {
        // Get the fractional part of the current time (ensures 0..1 interval)
        self.animation = complete - floorf(complete);
        [self setNeedsDisplay];
    }
}

#pragma mark - BFWDrawView

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
            DLog(@"No animation method for name: %@, so resorting to BFWDrawView implementation", self.name);
            invocation = [super drawInvocation];
        }
    }
    return invocation;
}

@end
