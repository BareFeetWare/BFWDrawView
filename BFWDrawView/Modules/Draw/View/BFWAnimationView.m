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

@interface BFWDrawView ()

@property (nonatomic, copy) NSArray *parameters;

- (void *)argumentForParameter:(NSString *)parameter;
- (BOOL)updateArgumentForParameter:(NSString *)parameter;

@end

@interface BFWAnimationView ()

@property (nonatomic, weak) NSTimer *timer; // NSRunLoop holds a strong reference
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *pausedDate;
@property (nonatomic, assign) NSTimeInterval pausedTimeInterval;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) NSUInteger drawnFrameCount; // to count actual frames drawn
@property (nonatomic, readonly) BOOL isAnimation;
@property (nonatomic, assign) CGFloat invokedAnimation;

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
        [self updateArgumentForParameter:@"animation"];
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

- (BOOL)isAnimation
{
    return [self.parameters containsObject:@"animation"];
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
    if (!self.timer && !self.paused && !self.finished && self.isAnimation) {
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

- (NSArray *)possibleParametersArray
{
    return @[@[@"frame", @"animation"],
             @[@"frame", @"tintColor", @"animation"],
             @[@"frame"],
             @[@"frame", @"tintColor"]
             ];
}

- (void *)argumentForParameter:(NSString *)parameter
{
    void *argument = nil;
    if ([parameter isEqualToString:@"animation"]) {
        self.invokedAnimation = [self animationBetweenStartAndEnd];
        argument = &_invokedAnimation;
    }
    else {
        argument = [super argumentForParameter:parameter];
    }
    return argument;
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
