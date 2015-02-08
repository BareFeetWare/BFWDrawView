//
//  BFWDrawButton.m
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawButton.h"
#import "BFWDrawView.h"

@implementation NSMutableDictionary (BFWDraw)

- (void)setValueOrRemoveNil:(id)valueOrNil forKey:(id)key
{
    if (valueOrNil) {
        self[key] = valueOrNil;
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end

@interface BFWDrawButton ()

@property (nonatomic, strong) NSMutableDictionary *iconDrawViewDict;
@property (nonatomic, strong) NSMutableDictionary *backgroundDrawViewDict;

@end

@implementation BFWDrawButton

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (frame.size.width > 0.0 && frame.size.height > 0.0) {
            [self commonInit];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [self commonInit];
}

- (void)commonInit
{
    // implement in subclasses
}

#pragma mark - accessors

- (NSMutableDictionary *)iconDrawViewDict
{
    if (!_iconDrawViewDict) {
        _iconDrawViewDict = [[NSMutableDictionary alloc] init];
    }
    return _iconDrawViewDict;
}

- (NSMutableDictionary *)backgroundDrawViewDict
{
    if (!_backgroundDrawViewDict) {
        _backgroundDrawViewDict = [[NSMutableDictionary alloc] init];
    }
    return _backgroundDrawViewDict;
}

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state
{
    return self.iconDrawViewDict[@(state)];
}

- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state
{
    return self.backgroundDrawViewDict[@(state)];
}

- (void)setIconDrawView:(BFWDrawView *)drawView forState:(UIControlState)state
{
    [self.iconDrawViewDict setValueOrRemoveNil:drawView forKey:@(state)];
    [self setImage:drawView.image forState:state];
}

- (void)setBackgroundDrawView:(BFWDrawView *)drawView forState:(UIControlState)state
{
    [self.backgroundDrawViewDict setValueOrRemoveNil:drawView forKey:@(state)];
    [self setBackgroundImage:drawView.image forState:state];
}

@end
