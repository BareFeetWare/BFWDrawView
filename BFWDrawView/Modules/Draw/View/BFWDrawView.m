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

static NSString * const sizesKey = @"sizes";
static NSString * const sizesByPrefixKey = @"sizesByPrefix";
static NSString * const derivedKey = @"derived";
static NSString * const baseKey = @"base";
static NSString * const sizeKey = @"size";
static NSString * const fillColorKey = @"fillColor";

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

+ (NSBundle *)bundle
{
#if TARGET_INTERFACE_BUILDER // rendering in storyboard using IBDesignable
    NSBundle *bundle = [NSBundle bundleForClass:self];
#else
    NSBundle *bundle = [NSBundle mainBundle];
#endif
    return bundle;
}

+ (NSDictionary *)parameterDictForStyleKit:(NSString *)styleKit
{
    NSString *path = [[self bundle] pathForResource:styleKit ofType:@"plist"];
    NSDictionary *parameterDict = [NSDictionary dictionaryWithContentsOfFile:path];
    return parameterDict;
}

- (NSDictionary *)parameterDict
{
    return [[self class] parameterDictForStyleKit:self.styleKit];
}

#pragma mark - frame calculations

- (CGSize)drawnSize
{
    if (_drawnSize.width == 0.0 && _drawnSize.height == 0.0) {
        NSString *sizeString = self.parameterDict[sizesKey][self.name];
        if (!sizeString) {
            NSDictionary *sizeByPrefixDict = self.parameterDict[sizesByPrefixKey];
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
    if (self.drawnSize.width && self.drawnSize.height) {
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
    else if (self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeScaleAspectFill || self.contentMode == UIViewContentModeScaleToFill) {
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
    else {
        drawFrame = CGRectMake(0, 0, self.drawnSize.width, self.drawnSize.height);
    }
    return drawFrame;
}

#pragma mark - drawing

- (NSString *)drawFrameSelectorString
{
    NSString *selectorString = [NSString stringWithFormat:@"draw%@WithFrame:", [self.name uppercaseFirstCharacter]];
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
            selectorString = [selectorString stringByAppendingString:@"fillColor:"];
            SEL selector = NSSelectorFromString(selectorString);
            if ([class respondsToSelector:selector]) {
                UIColor *fillColor = self.fillColor;
                NSValue *fillColorPointer = [NSValue valueWithPointer:&fillColor];
                _drawInvocation = [NSInvocation invocationForClass:class
                                                          selector:selector
                                                  argumentPointers:@[framePointer, fillColorPointer]];
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

- (void)setFillColor:(UIColor *)fillColor
{
    if (![_fillColor isEqual:fillColor]) {
        _fillColor = fillColor;
        [_drawInvocation setArgument:&fillColor atIndex:3];
        [self setNeedsDisplay];
    }
}

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        self.drawInvocation = nil;
        _name = name;
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
    if (self.fillColor) {
        NSString *colorString = [[CIColor colorWithCGColor:self.fillColor.CGColor] stringRepresentation];
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

- (BOOL)writeImageAtScale:(CGFloat)scale toFile:(NSString*)savePath
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

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        fillColor:(UIColor *)fillColor
                          android:(BOOL)isAndroid
{
    for (NSString *styleKit in styleKitArray) {
        NSDictionary *parameterDict = [self parameterDictForStyleKit:styleKit];
        Class styleKitClass = NSClassFromString(styleKit);
        NSArray *drawingNames = [[styleKitClass drawParameterDict] allKeys];
        for (NSString *drawingName in drawingNames) {
            BFWDrawView *drawView = [[BFWDrawView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
            drawView.name = drawingName;
            drawView.styleKit = styleKit;
            CGSize size = drawView.drawnSize;
            if (!size.width || !size.height) {
                DLog(@"missing size for drawing: %@", drawingName);
            }
            else {
                drawView.frame = CGRectMake(0, 0, size.width, size.height);
                drawView.fillColor = fillColor;
                NSString *fileName = isAndroid ? [drawingName androidFileName] : drawingName;
                [drawView writeImagesToDirectory:directoryPath
                                   pathScaleDict:pathScaleDict
                                            size:size
                                        fileName:fileName];
            }
        }
        for (NSString *drawingName in parameterDict[derivedKey]) {
            NSDictionary *derivedDict = parameterDict[derivedKey][drawingName];
            NSString *baseName = derivedDict[baseKey];
            NSString *sizeString = derivedDict[sizeKey] ? derivedDict[sizeKey] : parameterDict[sizesKey][baseName];
            if (sizeString) {
                CGSize size = CGSizeFromString(sizeString);
                UIColor *useFillColor = fillColor;
                NSString *fillColorString = derivedDict[fillColorKey];
                if (fillColorString) {
                    useFillColor = [styleKitClass colorWithName:fillColorString];
                }
                if (size.width && size.height) {
                    BFWDrawView *drawView = [[BFWDrawView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                    drawView.name = baseName;
                    drawView.styleKit = styleKit;
                    drawView.fillColor = useFillColor;
                    drawView.contentMode = UIViewContentModeScaleAspectFit;
                    NSString *fileName = isAndroid ? [drawingName androidFileName] : drawingName;
                    [drawView writeImagesToDirectory:directoryPath
                                       pathScaleDict:pathScaleDict
                                                size:size
                                            fileName:fileName];
                }
            }
        }
    }
}

- (void)writeImagesToDirectory:(NSString *)directoryPath
                 pathScaleDict:(NSDictionary *)pathScaleDict
                          size:(CGSize)size
                      fileName:(NSString *)fileName
{
    for (NSString *path in pathScaleDict) {
        NSNumber *scaleNumber = pathScaleDict[path];
        CGFloat scale = [scaleNumber floatValue];
        NSString *relativePath;
        if ([path containsString:@"%@"]) {
            relativePath = [NSString stringWithFormat:path, fileName];
        }
        else {
            relativePath = [path stringByAppendingPathComponent:fileName];
        }
        NSString *filePath = [directoryPath stringByAppendingPathComponent:relativePath];
        filePath = [filePath stringByAppendingPathExtension:@"png"];
        BOOL success = [self writeImageAtScale:scale toFile:filePath];
        if (!success) {
            NSLog(@"failed to write %@", relativePath);
        }
    }
}

@end
