//
//  BFWDrawView.m
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawView.h"
#import "UIImage+BareFeetWare.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/objc-runtime.h>

@implementation NSArray (BFWDrawView)

- (NSArray *)arrayByReplacingFirstObjectWithReplaceDict:(NSDictionary *)replaceDict
{
    NSArray *replacedArray = self;
    for (NSString *oldPrefix in replaceDict) {
        NSString *firstString = [[self firstObject] lowercaseString];
        if ([firstString isEqualToString:oldPrefix]) {
            NSString *newPrefix = replaceDict[oldPrefix];
            NSMutableArray *wordsMutable = [replacedArray mutableCopy];
            wordsMutable[0] = newPrefix;
            replacedArray = [wordsMutable copy];
        }
    }
    return replacedArray;
}

@end

@implementation NSString (BFWDrawView)

- (NSString *)uppercaseFirstCharacter // only uppercase first character in string
{
    NSString *uppercaseFirstString = [[self substringToIndex:1] uppercaseString];
    uppercaseFirstString = [uppercaseFirstString stringByAppendingString:[self substringFromIndex:1]];
    return uppercaseFirstString;
}

- (NSString *)lowercaseFirstCharacter // only lowercase first character in string
{
    NSString *lowercaseFirstString = [[self substringToIndex:1] lowercaseString];
    lowercaseFirstString = [lowercaseFirstString stringByAppendingString:[self substringFromIndex:1]];
    return lowercaseFirstString;
}

- (BOOL)isUppercase
{
    return [self isEqualToString:self.uppercaseString];
}

- (NSString *)camelToWords
{
    NSMutableString *wordString = [[NSMutableString alloc] init];
    NSString *previousChar = nil;
    for (NSUInteger charN = 0; charN < self.length; charN++) {
        NSString *thisChar = [self substringWithRange:NSMakeRange(charN, 1)];
        NSString *nextChar = charN + 1 < self.length ? [self substringWithRange:NSMakeRange(charN + 1, 1)] : nil;
        if (charN > 0 && [thisChar isUppercase] && (![previousChar isUppercase] || (nextChar && ![nextChar isUppercase]))) {
            [wordString appendString:@" "];
        }
        [wordString appendString:thisChar];
        previousChar = thisChar;
    }
    return [NSString stringWithString:wordString];
}

- (NSArray *)methodNameComponents
{
    static NSString * const withString = @"With";
    
    NSArray *parameters = nil;
    if ([self hasSuffix:@":"]) {
        NSArray *parameterComponents = [self componentsSeparatedByString:@":"];
        NSArray *withComponents = [parameterComponents.firstObject componentsSeparatedByString:withString];
        NSString *methodBaseName = [[withComponents subarrayWithRange:NSMakeRange(0, withComponents.count - 1)] componentsJoinedByString:withString];
        NSString *firstParameter = [withComponents.lastObject lowercaseFirstCharacter];
        NSMutableArray *mutableParameters = [[NSMutableArray alloc] init];
        [mutableParameters addObject:methodBaseName];
        [mutableParameters addObject:firstParameter];
        [mutableParameters addObjectsFromArray:[parameterComponents subarrayWithRange:NSMakeRange(1, parameterComponents.count - 2)]];
        parameters = [mutableParameters copy];
    }
    else {
        parameters = @[self];
    }
    return parameters;
}

- (NSString *)androidFileName
{
    NSArray *words = [[self camelToWords] componentsSeparatedByString:@" "];
    NSDictionary *replacePrefixDict = @{@"button" : @"btn",
                                        @"icon" : @"ic"};
    words = [words arrayByReplacingFirstObjectWithReplaceDict:replacePrefixDict];
    NSString *fileName = [[words componentsJoinedByString:@"_"] lowercaseString];
    return fileName;
}

@end

@implementation NSInvocation (BFWDrawView)

+ (NSInvocation *)invocationForClass:(Class)class
                            selector:(SEL)selector
                    argumentPointers:(NSArray *)argumentPointers
{
    NSInvocation *invocation;
    if ([class respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:selector];
        [invocation setTarget:class];
        for (NSUInteger argumentN = 0; argumentN < argumentPointers.count; argumentN++) {
            NSValue *argumentAddress = argumentPointers[argumentN];
            [invocation setArgument:argumentAddress.pointerValue atIndex:argumentN + 2];
        }
    }
    return invocation;
}

@end

@implementation NSObject (BFWDrawView)

#pragma mark - Introspection

+ (NSArray *)methodNames
{
    NSMutableArray *methodNames = [[NSMutableArray alloc] init];
    int unsigned methodCount;
    Method *methods = class_copyMethodList(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]), &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        [methodNames addObject:methodName];
    }
    return [methodNames copy];
}

+ (NSDictionary *)classMethodValueDict
{
    static NSString * const classType = @"@";
    static NSString * const voidType = @"v";
    
    NSMutableDictionary *methodDict = [[NSMutableDictionary alloc] init];
    int unsigned methodCount;
    Method *methods = class_copyMethodList(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]), &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        char *returnType = method_copyReturnType(method);
        NSString *typeString = [NSString stringWithUTF8String:returnType];
        free((void*)returnType);
        id returnValue;
        if ([typeString isEqualToString:classType]) {
            // Danger: calling method may have side effects
            NSInvocation *invocation = [NSInvocation invocationForClass:[self class]
                                                               selector:NSSelectorFromString(methodName) // TODO: more direct way
                                                       argumentPointers:nil];
            [invocation invoke];
            [invocation getReturnValue:&returnValue];
        }
        else if ([typeString isEqualToString:voidType]) {
            returnValue= [NSNull null];
            NSLog(@"void type = %s", returnType);
        }
        else {
            DLog(@"**** unexpected returnType = %s", returnType);
        }
        if (returnValue) {
            methodDict[methodName] = returnValue;
        }
    }
    free(methods);
    return [methodDict copy];
}

+ (NSDictionary *)methodParametersDict
{
    NSMutableDictionary *methodParametersDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        NSArray *methodNameComponents = [methodName methodNameComponents];
        methodParametersDict[methodName] = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
    }
    return [methodParametersDict copy];
}

#pragma mark - Introspection for StyleKit classes produced by PaintCode

+ (NSDictionary *)colorDict
{
    NSMutableDictionary *colorDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        id returnValue = methodValueDict[methodName];
        if ([returnValue isKindOfClass:[UIColor class]]) {
            colorDict[methodName] = returnValue;
        }
    }
    return [colorDict copy];
}

+ (NSDictionary *)drawParameterDict
{
    static NSString * const drawPrefix = @"draw";
    NSMutableDictionary *methodParametersDict = [[NSMutableDictionary alloc] init];
    NSDictionary *methodValueDict = [[self class] classMethodValueDict];
    for (NSString *methodName in methodValueDict) {
        id returnValue = methodValueDict[methodName];
        if ([returnValue isKindOfClass:[NSNull class]] && [methodName hasPrefix:drawPrefix]) {
            NSArray *methodNameComponents = [methodName methodNameComponents];
            NSString *drawName = [[methodNameComponents.firstObject substringFromIndex:drawPrefix.length] lowercaseFirstCharacter];
            methodParametersDict[drawName] = [methodNameComponents subarrayWithRange:NSMakeRange(1, methodNameComponents.count - 1)];
        }
    }
    return [methodParametersDict copy];
}

@end

@implementation UIColor (BFWDrawView)

+ (UIColor *)colorWithName:(NSString *)colorName
                  styleKit:(NSString *)styleKit
{
    UIColor *color;
    Class styleKitClass = NSClassFromString(styleKit);
    SEL selector = NSSelectorFromString(colorName);
    NSInvocation *invocation = [NSInvocation invocationForClass:styleKitClass
                                                       selector:selector
                                               argumentPointers:nil];
    UIColor *foundColor;
    [invocation invoke];
    [invocation getReturnValue:&foundColor];
    if ([foundColor isKindOfClass:[UIColor class]]) {
        color = foundColor;
    }
    else {
        DLog(@"failed to find color name: %@", colorName);
    }
    return color;
}

@end

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
        for (NSString *drawingName in [parameterDict[sizesKey] allKeys]) {
            NSString *sizeString = parameterDict[sizesKey][drawingName];
            if (sizeString) {
                CGSize size = CGSizeFromString(sizeString);
                if (size.width && size.height) {
                    BFWDrawView *drawView = [[BFWDrawView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                    drawView.name = drawingName;
                    drawView.styleKit = styleKit;
                    drawView.fillColor = fillColor;
                    NSString *fileName = isAndroid ? [drawingName androidFileName] : drawingName;
                    [drawView writeImagesToDirectory:directoryPath
                                       pathScaleDict:pathScaleDict
                                                size:size
                                            fileName:fileName];
                }
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
                    useFillColor = [UIColor colorWithName:fillColorString
                                                 styleKit:styleKit];
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
