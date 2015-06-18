//
//  BFWDrawButton.m
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawButton.h"
#import "BFWDrawView.h"
#import "UIView+BFW.h"

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

@property (nonatomic, strong) NSMutableDictionary *iconDrawViewForStateDict;
@property (nonatomic, strong) NSMutableDictionary *backgroundDrawViewForStateDict;
@property (nonatomic, strong) NSMutableDictionary *shadowForStateDict;
@property (nonatomic, assign) BOOL needsUpdateShadow;

@end

@implementation BFWDrawButton

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
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

- (void)commonInit
{
    // implement in subclasses if required and call super
}

#pragma mark - accessors

- (NSMutableDictionary *)iconDrawViewForStateDict
{
    if (!_iconDrawViewForStateDict) {
        _iconDrawViewForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _iconDrawViewForStateDict;
}

- (NSMutableDictionary *)backgroundDrawViewForStateDict
{
    if (!_backgroundDrawViewForStateDict) {
        _backgroundDrawViewForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _backgroundDrawViewForStateDict;
}

- (NSMutableDictionary *)shadowForStateDict
{
    if (!_shadowForStateDict) {
        _shadowForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _shadowForStateDict;
}

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state
{
    return self.iconDrawViewForStateDict[@(state)];
}

- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state
{
    return self.backgroundDrawViewForStateDict[@(state)];
}

- (void)setIconDrawView:(BFWDrawView *)drawView
               forState:(UIControlState)state
{
    [self.iconDrawViewForStateDict setValueOrRemoveNil:drawView
                                             forKey:@(state)];
    [self setImage:drawView.image forState:state];
}

- (void)setBackgroundDrawView:(BFWDrawView *)drawView
                     forState:(UIControlState)state
{
    BOOL canDraw = drawView.canDraw;
    if (!canDraw) {
        drawView = nil;
    }
    [self.backgroundDrawViewForStateDict setValueOrRemoveNil:drawView
                                                   forKey:@(state)];
    [self setNeedsLayout];
}

- (void)makeIconDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                  styleKit:(NSString *)styleKit
{
    self.iconDrawViewForStateDict = nil;
    for (NSNumber *stateNumber in stateNameDict) {
        BFWDrawView *icon = [[BFWDrawView alloc] init];
        icon.name = stateNameDict[stateNumber];
        icon.styleKit = styleKit;
        icon.contentMode = UIViewContentModeRedraw;
        icon.frame = CGRectMake(0, 0, icon.drawnSize.width, icon.drawnSize.height);
        [self setIconDrawView:icon
                     forState:stateNumber.integerValue];
    }
}

- (void)makeBackgroundDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                        styleKit:(NSString *)styleKit
{
    self.backgroundDrawViewForStateDict = nil;
    for (NSNumber *stateNumber in stateNameDict) {
        BFWDrawView *background = [[BFWDrawView alloc] initWithFrame:self.bounds];
        background.name = stateNameDict[stateNumber];
        background.styleKit = styleKit;
        background.contentMode = UIViewContentModeRedraw;
        [self setBackgroundDrawView:background
                           forState:stateNumber.integerValue];
    }
}

- (NSShadow *)shadowForState:(UIControlState)state
{
    return self.shadowForStateDict[@(state)];
}

- (void)setShadow:(NSShadow *)shadow
         forState:(UIControlState)state
{
    [self.shadowForStateDict setValueOrRemoveNil:shadow
                                          forKey:@(state)];
    self.needsUpdateShadow = YES;
}

- (void)setNeedsUpdateShadow:(BOOL)needsUpdateShadow
{
    _needsUpdateShadow = needsUpdateShadow;
    if (needsUpdateShadow) {
        [self setNeedsDisplay];
    }
}

#pragma mark - updates

- (void)updateBackgrounds
{
    for (NSNumber *stateNumber in self.backgroundDrawViewForStateDict) {
        BFWDrawView *background = self.backgroundDrawViewForStateDict[stateNumber];
        background.frame = self.bounds;
        [self setBackgroundImage:background.image forState:stateNumber.integerValue];
    }
}

- (void)updateShadowIfNeeded
{
    if (self.needsUpdateShadow) {
        NSShadow *shadow = [self shadowForState:self.state];
        if (!shadow) {
            shadow = [self shadowForState:UIControlStateNormal];
        }
        [self applyShadow:shadow];
        self.needsUpdateShadow = NO;
    }
}

#pragma mark - UIButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.needsUpdateShadow = YES;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.needsUpdateShadow = YES;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.needsUpdateShadow = YES;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [self updateBackgrounds];
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self updateShadowIfNeeded];
}

@end
