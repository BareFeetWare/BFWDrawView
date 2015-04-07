//
//  BFWDrawView.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawView.h"
#import "UIImage+BFW.h"
#import "NSInvocation+BFW.h"
#import "NSString+BFW.h"
#import "NSObject+BFWStyleKit.h"
#import <QuartzCore/QuartzCore.h>

@interface BFWDrawView ()

@end

NSString * const sizesKey = @"sizes";
NSString * const sizesByPrefixKey = @"sizesByPrefix";

@implementation BFWDrawView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;  // forces redraw when view is resized, eg when device is rotated
    }
    return self;
}

#pragma mark - accessors

- (Class)styleKitClass
{
    return NSClassFromString(self.styleKit);
}

#pragma mark - frame calculations

- (CGSize)drawnSize
{
    if (CGSizeEqualToSize(_drawnSize, CGSizeZero)) {
        NSDictionary *parameterDict = [self.styleKitClass parameterDict];
        NSString *sizeString = parameterDict[sizesKey][self.name];
        if (!sizeString) {
            NSDictionary *sizeByPrefixDict = parameterDict[sizesByPrefixKey];
            NSArray *sortedKeys = [sizeByPrefixDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                // sort from longest to shortest so more specific (longer) match is found first
                return obj1.length > obj2.length ? NSOrderedAscending : NSOrderedDescending;
            }];
            for (NSString *prefix in sortedKeys) {
                if ([self.name hasPrefix:prefix]) {
                    sizeString = sizeByPrefixDict[prefix];
                    break;
                }
            }
        }
        _drawnSize = sizeString ? CGSizeFromString(sizeString) : self.frame.size;
    }
    return _drawnSize;
}

- (CGSize)intrinsicContentSize
{
    CGSize size = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    if (!CGSizeEqualToSize(self.drawnSize, CGSizeZero)) {
        size = self.drawnSize;
    }
    return size;
}

- (CGRect)drawFrame
{
    CGRect drawFrame = CGRectZero;
    if (self.contentMode == UIViewContentModeCenter) {
        drawFrame = CGRectMake((self.frame.size.width - self.drawnSize.width) / 2, (self.frame.size.height - self.drawnSize.height) / 2, self.drawnSize.width, self.drawnSize.height);
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeScaleAspectFill) {
        CGFloat widthScale = self.frame.size.width / self.drawnSize.width;
        CGFloat heightScale = self.frame.size.height / self.drawnSize.height;
        CGFloat scale;
        if (self.contentMode == UIViewContentModeScaleAspectFit) {
            scale = widthScale > heightScale ? heightScale : widthScale;
        }
        else {
            scale = widthScale > heightScale ? widthScale : heightScale;
        }
        drawFrame.size = CGSizeMake(self.drawnSize.width * scale, self.drawnSize.height * scale);
        drawFrame.origin.x = (self.frame.size.width - drawFrame.size.width) / 2.0;
        drawFrame.origin.y = (self.frame.size.height - drawFrame.size.height) / 2.0;
    }
    else if (self.contentMode == UIViewContentModeScaleToFill || self.contentMode == UIViewContentModeRedraw) {
        drawFrame = self.bounds;
    }
    else {
        drawFrame = CGRectMake(0, 0, self.drawnSize.width, self.drawnSize.height);
        if (self.contentMode == UIViewContentModeTopLeft) {
            // leave as-is
        }
        if (self.contentMode == UIViewContentModeTopRight || self.contentMode == UIViewContentModeBottomRight || self.contentMode == UIViewContentModeRight) {
            drawFrame.origin.x = self.bounds.size.width - self.drawnSize.width;
        }
        if (self.contentMode == UIViewContentModeBottomLeft || self.contentMode == UIViewContentModeBottomRight || self.contentMode == UIViewContentModeBottom) {
            drawFrame.origin.y = self.bounds.size.height - self.drawnSize.height;
        }
    }
    return drawFrame;
}

#pragma mark - layout

- (void)layoutSubviews
{
    // layoutSubviews is called when constraints change. Since new constraints might resize this view, we need to redraw.
    // TODO: only redraw if size actually changed
    self.drawInvocation = nil;
    [self setNeedsDisplay];
    [super layoutSubviews];
}

#pragma mark - drawing

- (NSString *)drawFrameSelectorString
{
    NSString *nameWithoutSpaces = [self.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *selectorString = [NSString stringWithFormat:@"draw%@WithFrame:", [nameWithoutSpaces uppercaseFirstCharacter]];
    return selectorString;
}

- (NSInvocation *)drawInvocation
{
    Class class = self.styleKitClass;
    if (!class) {
        DLog(@"**** error: Failed to get styleKitClass to draw %@", self.name);
        return nil;
    }
    if (!_drawInvocation) {
        NSString *selectorString = [self drawFrameSelectorString];
        CGRect frame = self.drawFrame;
        NSValue *framePointer = [NSValue valueWithPointer:&frame];
        SEL selector = NSSelectorFromString(selectorString);
        if ([class respondsToSelector:selector]) {
            _drawInvocation = [NSInvocation invocationForClass:class
                                                      selector:selector
                                              argumentPointers:@[framePointer]];
        }
        else {
            selectorString = [selectorString stringByAppendingString:@"tintColor:"];
            SEL selector = NSSelectorFromString(selectorString);
            if ([class respondsToSelector:selector]) {
                UIColor *tintColor = self.tintColor;
                NSValue *tintColorPointer = [NSValue valueWithPointer:&tintColor];
                _drawInvocation = [NSInvocation invocationForClass:class
                                                          selector:selector
                                                  argumentPointers:@[framePointer, tintColorPointer]];
            }
            else {
                DLog(@"**** error: No method for drawing name: %@", self.name);
            }
        }
    }
    return _drawInvocation;
}

- (BOOL)canDraw
{
    return self.drawInvocation ? YES : NO;
}

- (void)drawRect:(CGRect)rect
{
    [[self drawInvocation] invoke];
}


#pragma mark - setters

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        _name = name;
        self.drawInvocation = nil;
        [self setNeedsDisplay];
    }
}

#pragma mark - image rendering

+ (NSMutableDictionary *)imageCache
{
    static NSMutableDictionary *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSMutableDictionary alloc] init];
    });
    return imageCache;
}

- (NSString *)cacheKey
{
    NSMutableArray *components = [@[self.name, self.styleKit, NSStringFromCGSize(self.frame.size)] mutableCopy];
    if (self.tintColor) {
        NSString *colorString = [[CIColor colorWithCGColor:self.tintColor.CGColor] stringRepresentation];
        [components addObject:colorString];
    }
    NSString *key = [components componentsJoinedByString:@"."];
    return key;
}

- (UIImage*)imageFromView
{
    UIImage *image = nil;
    if (self.name && self.styleKit) {
        NSString *key = [self cacheKey];
        image = [self class].imageCache[key];
        if (!image) {
            image = [UIImage imageOfView:self size:self.frame.size];
            if (image) {
                [self class].imageCache[key] = image;
            }
        }
    }
    else {
        DLog(@"**** error: Missing name or styleKit");
    }
    return image;
}

- (UIImage*)image
{
    return [self imageFromView];
}

#pragma mark - image output methods

- (BOOL)writeImageAtScale:(CGFloat)scale
                   toFile:(NSString*)savePath
{
    NSString *directoryPath = [savePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    BOOL success = NO;
    UIImage *image = [self imageAtScale:scale];
    if (image) {
        success = [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
    }
    return success;
}

- (UIImage*)imageAtScale:(CGFloat)scale
{
    UIImage *image = nil;
    if (self.canDraw) {
        BOOL isOpaque = NO;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, isOpaque, scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
