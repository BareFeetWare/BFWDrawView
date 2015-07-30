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
#import "NSObject+BFWStyleKit.h" // for DLog

@interface BFWDrawView ()

@property (nonatomic, strong) NSInvocation *drawInvocation;

- (CGRect)drawFrame;
- (NSArray *)parameters;
- (SEL)drawingSelector;
- (Class)drawingClass;

@end

@interface BFWAnimationView ()

@property (nonatomic, weak) NSTimer *timer; // NSRunLoop holds a strong reference
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *pausedDate;
@property (nonatomic, assign) NSTimeInterval pausedTimeInterval;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) NSUInteger drawnFrameCount; // to count actual frames drawn

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
    _framesPerSecond = 30.0;
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
        [self setArgumentPointer:[NSValue valueWithPointer:&animation]
                    forParameter:@"animation"];
        [self setNeedsDisplay];
    }
}

- (CGFloat)animationBetweenStartAndEnd
{
    CGFloat animation = self.animation;
    if (self.start || self.end) {
        animation = self.start + self.animation * (self.end - self.start);
    }
    return animation;
}

- (CGFloat)drawnFramesPerSecond
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    return interval > 0 ? self.drawnFrameCount / interval : 0.0;
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
            self.drawnFrameCount = 0;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.framesPerSecond
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
    if (self.paused || self.finished || !self.superview) {
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

- (BOOL)writeImagesAtScale:(CGFloat)scale
                    toFile:(NSString *)filePath;
{
    BOOL success = NO;
    if (self.paused) {
        success = [self writeImageAtScale:scale
                                   toFile:filePath];
    }
    else {
        NSUInteger frameCount = self.duration * self.framesPerSecond;
        NSUInteger digits = log10((double)frameCount) + 1;
        NSString* pathBaseFormat = [filePath.stringByDeletingPathExtension stringByAppendingFormat:@"%%0%lud", (unsigned long)digits];
        NSString *pathFormat = [pathBaseFormat stringByAppendingPathExtension:filePath.pathExtension];
        for (NSUInteger frameN = 0; frameN < frameCount; frameN++) {
            self.animation = (CGFloat)frameN / frameCount;
            NSString *imagePath = [NSString stringWithFormat:pathFormat, frameN];
            BOOL frameSuccess = [self writeImageAtScale:scale
                                                 toFile:imagePath];
            if (frameN == 0) {
                success = frameSuccess;
            }
            else {
                success = success && frameSuccess;
            }
        }
    }
    return success;
}

#pragma mark - BFWDrawView

- (NSInvocation *)drawInvocation
{
    if (!self.isDrawInvocationInstantiated) {
        NSMutableArray *argumentPointers = [[NSMutableArray alloc] init];
        // Declare local variable copies in same scope as call to NSInvocation so they are retained
        // TODO: find a way to remove the duplicated code from here (and BFWDrawView) while satisfying argumentPointers
        CGRect frame = [self drawFrame];
        UIColor *tintColor = self.tintColor;
        CGFloat animation = [self animationBetweenStartAndEnd];
        for (NSString *parameter in self.parameters) {
            NSValue *argumentPointer = nil;
            if ([parameter isEqualToString:@"frame"]) {
                argumentPointer = [NSValue valueWithPointer:&frame];
            }
            else if ([parameter isEqualToString:@"tintColor"]) {
                argumentPointer = [NSValue valueWithPointer:&tintColor];
            }
            else if ([parameter isEqualToString:@"animation"]) {
                argumentPointer = [NSValue valueWithPointer:&animation];
            }
            if (argumentPointer) {
                [argumentPointers addObject:argumentPointer];
            }
            else {
                DLog(@"**** error: unexpected parameter: %@", parameter);
                argumentPointers = nil;
                break;
            }
        }
        if (argumentPointers) {
            super.drawInvocation = [NSInvocation invocationForClass:self.drawingClass
                                                           selector:self.drawingSelector
                                                   argumentPointers:argumentPointers];
        }
    }
    return super.drawInvocation;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
    [self startTimerIfNeeded];
    self.drawnFrameCount++;
    [super drawRect:rect];
}

- (void)setHidden:(BOOL)hidden
{
    BOOL wasHidden = super.hidden;
    [super setHidden:hidden];
    if (hidden != wasHidden) {
        if (hidden) {
            [self.timer invalidate];
        } else {
            [self startTimerIfNeeded];
        }
    }
}

@end
