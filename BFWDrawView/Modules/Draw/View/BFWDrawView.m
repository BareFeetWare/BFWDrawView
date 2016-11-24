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

@synthesize styleKit = _styleKit;
@synthesize name = _name;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        super.backgroundColor = [UIColor clearColor];
        super.contentMode = UIViewContentModeRedraw;  // forces redraw when view is resized, eg when device is rotated
    }
    return self;
}

#pragma mark - accessors

- (Class)styleKitClass
{
    return self.drawing.styleKit.paintCodeClass;
}

- (BFWStyleKitDrawing *)drawing
{
    if (!_drawing) {
        _drawing = [BFWStyleKit drawingForStyleKitName:_styleKit
                                           drawingName:_name];
    }
    return _drawing;
}

- (NSString *)styleKit
{
    return self.drawing.styleKit.name ?: _styleKit;
}

- (NSString *)name
{
    return self.drawing.name ?: _name;
}

- (void)setStyleKit:(NSString *)styleKit
{
    if (![_styleKit isEqualToString:styleKit]) {
        _styleKit = styleKit;
        self.drawInvocation = nil;
        self.drawing = nil;
        [self setNeedsDisplay];
    }
}

- (void)setFillColor:(UIColor *)fillColor // Deprecated. Use UIView's tintColor.
{
    BFWDLog(@"BFWDrawView called deprecated fillColor. Use tintColor instead. %@", fillColor
         );
    self.tintColor = fillColor;
    _fillColor = fillColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (![super.tintColor isEqual:tintColor]) {
        [super setTintColor:tintColor];
        self.drawInvocation = nil;
        [self setNeedsDisplay]; // needed?
    }
}

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        _name = name;
        self.drawInvocation = nil;
        self.drawing = nil;
        [self setNeedsDisplay];
    }
}

#pragma mark - frame calculations

- (CGSize)drawnSize
{
    return self.drawInFrameSize;
}

- (CGSize)drawInFrameSize
{
    return self.drawing.hasDrawnSize ? self.drawing.drawnSize : self.frame.size;
}

- (CGSize)intrinsicContentSize
{
    CGSize size = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    if (self.drawing.hasDrawnSize) {
        size = self.drawing.drawnSize;
    }
    return size;
}

- (CGRect)drawFrame
{
    CGRect drawFrame = CGRectZero;
    if (self.contentMode == UIViewContentModeCenter) {
        drawFrame = CGRectMake((self.frame.size.width - self.drawInFrameSize.width) / 2,
                               (self.frame.size.height - self.drawInFrameSize.height) / 2,
                               self.drawInFrameSize.width,
                               self.drawInFrameSize.height);
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeScaleAspectFill) {
        CGFloat widthScale = self.frame.size.width / self.drawInFrameSize.width;
        CGFloat heightScale = self.frame.size.height / self.drawInFrameSize.height;
        CGFloat scale;
        if (self.contentMode == UIViewContentModeScaleAspectFit) {
            scale = widthScale > heightScale ? heightScale : widthScale;
        }
        else {
            scale = widthScale > heightScale ? widthScale : heightScale;
        }
        drawFrame.size = CGSizeMake(self.drawInFrameSize.width * scale,
                                    self.drawInFrameSize.height * scale);
        drawFrame.origin.x = (self.frame.size.width - drawFrame.size.width) / 2.0;
        drawFrame.origin.y = (self.frame.size.height - drawFrame.size.height) / 2.0;
    }
    else if (self.contentMode == UIViewContentModeScaleToFill || self.contentMode == UIViewContentModeRedraw) {
        drawFrame = self.bounds;
    }
    else {
        drawFrame = CGRectMake(0, 0, self.drawInFrameSize.width,
                               self.drawInFrameSize.height);
        if (self.contentMode == UIViewContentModeTopLeft) {
            // leave as-is
        }
        if (self.contentMode == UIViewContentModeTopRight || self.contentMode == UIViewContentModeBottomRight || self.contentMode == UIViewContentModeRight) {
            drawFrame.origin.x = self.bounds.size.width - self.drawInFrameSize.width;
        }
        if (self.contentMode == UIViewContentModeBottomLeft || self.contentMode == UIViewContentModeBottomRight || self.contentMode == UIViewContentModeBottom) {
            drawFrame.origin.y = self.bounds.size.height - self.drawInFrameSize.height;
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

- (NSArray *)parameters {
    return self.drawing.methodParameters;
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
    NSString *colorString = self.tintColor.description;
    if (colorString) {
        [components addObject:colorString];
    }
    NSString *key = [components componentsJoinedByString:@"."];
    return key;
}

- (UIImage *)cachedImageForKey:(NSString *)key
{
    return [self class].imageCache[key];
}

- (void)setCachedImage:(UIImage *)image
                forKey:(NSString *)key
{
    [self class].imageCache[key] = image;
}

- (UIImage *)imageFromView
{
    UIImage *image = nil;
    if (self.name && self.styleKit) {
        NSString *key = [self cacheKey];
        image = [self cachedImageForKey:key];
        if (!image) {
            image = [UIImage imageOfView:self
                                    size:self.frame.size];
            if (image) {
                [self setCachedImage:image
                              forKey:key];
            }
        }
    }
    else {
        BFWDLog(@"**** error: Missing name or styleKit");
    }
    return image;
}

- (UIImage *)image
{
    return [self imageFromView];
}

#pragma mark - image output

- (BOOL)writeImageAtScale:(CGFloat)scale
                 isOpaque:(BOOL)isOpaque
                   toFile:(NSString *)savePath
{
    NSString *directoryPath = [savePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    BOOL success = NO;
    UIImage *image = [self imageAtScale:scale isOpaque:isOpaque];
    if (image) {
        success = [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
    }
    return success;
}

- (UIImage *)imageAtScale:(CGFloat)scale isOpaque:(BOOL)isOpaque
{
    UIImage *image = nil;
    if (self.canDraw) {
        CGFloat savedContentsScale = self.contentScaleFactor;
        self.contentScaleFactor = scale;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, isOpaque, scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contentScaleFactor = savedContentsScale;
    }
    return image;
}

#pragma mark - protocols for UIView+BFW

- (void)copyPropertiesFromView:(BFWDrawView *)view
{
    [super copyPropertiesFromView:view];
    self.styleKit = view.styleKit;
    self.name = view.name;
}

@end
