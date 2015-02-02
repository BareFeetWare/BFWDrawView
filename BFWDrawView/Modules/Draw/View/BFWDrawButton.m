//
//  BFWDrawButton.m
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Permission granted for use by CBA.
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
    _backgroundContentMode = UIViewContentModeRedraw;
    [self commonSubclassInit];
}

- (void)commonSubclassInit
{
    // implement in subclasses
}

#pragma mark - KVO

- (NSArray *)backgroundUpdateKeyPaths
{
    return @[@"contentMode"];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    [super setValue:value forKeyPath:keyPath];
    if ([[self backgroundUpdateKeyPaths] containsObject:keyPath]) {
        [self updateBackground];
    }
}

#pragma mark - drawing

- (void)updateBackground
{
    for (NSNumber *stateNumber in self.backgroundDrawNameDict) {
        BFWDrawView *drawView = [[BFWDrawView alloc] initWithFrame:self.bounds];
        drawView.styleKit = self.styleKit;
        drawView.name = self.backgroundDrawNameDict[stateNumber];
        drawView.contentMode = self.backgroundContentMode;
        UIImage *image = drawView.image;
        if (image) {
            UIControlState state = [stateNumber integerValue];
            [self setBackgroundImage:image forState:state];
        }
    }
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

- (void)setBackgroundDrawNameDict:(NSMutableDictionary *)backgroundDrawNameDict
{
    if (_backgroundDrawNameDict != backgroundDrawNameDict) {
        _backgroundDrawNameDict = backgroundDrawNameDict;
        [self updateBackground];
    }
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
    [self setImage:drawView.image forState:UIControlStateNormal];
}

- (void)setBackgroundDrawView:(BFWDrawView *)drawView forState:(UIControlState)state
{
    [self.backgroundDrawViewDict setValueOrRemoveNil:drawView forKey:@(state)];
    [self setBackgroundImage:drawView.image forState:UIControlStateNormal];
}

@end
