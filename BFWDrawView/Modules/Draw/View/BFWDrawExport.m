//
//  BFWDrawExport.m
//
//  Created by Tom Brodhurst-Hill on 23/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawExport.h"
#import "NSObject+BFWStyleKit.h"
#import "BFWAnimationView.h"
#import "NSString+BFW.h"
#import "BFWStyleKit.h"
#import "BFWStyleKitDrawing.h"

@implementation NSArray (BFW)

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

@implementation NSString (BFWDrawExport)

- (NSString *)androidFileName
{
    NSArray *words = [[self camelCaseToWords] componentsSeparatedByString:@" "];
    NSDictionary *replacePrefixDict = @{@"button" : @"btn",
                                        @"icon" : @"ic"};
    words = [words arrayByReplacingFirstObjectWithReplaceDict:replacePrefixDict];
    NSString *fileName = [[words componentsJoinedByString:@"_"] lowercaseString];
    return fileName;
}

@end

static NSString * const baseKey = @"base";
static NSString * const sizeKey = @"size";
static NSString * const tintColorKey = @"tintColor";
static NSString * const derivedKey = @"derived";
static NSString * const exportBlacklistKey = @"exportBlacklist";
static NSString * const animationKey = @"animation";
static NSString * const arrayKey = @"array";
static NSString * const arraysKey = @"arrays";

@implementation BFWDrawExport

+ (BFWDrawView *)drawViewForName:(NSString *)drawingName
                        styleKit:(NSString *)styleKit
                       tintColor:(UIColor *)tintColor
{
    BFWDrawView *drawView = nil;
    BFWStyleKitDrawing *drawing = [BFWStyleKit drawingForStyleKitName:styleKit
                                                          drawingName:drawingName];
    if (drawing.hasDrawnSize) {
        BOOL isAnimation = [drawing.methodParameters containsObject:@"animation"];
        Class class = isAnimation ? [BFWAnimationView class] : [BFWDrawView class];
        drawView = [[class alloc] initWithFrame:drawing.intrinsicFrame];
        drawView.drawing = drawing;
        drawView.contentMode = UIViewContentModeScaleAspectFit;
        drawView.tintColor = tintColor;
    } else {
        DLog(@"missing size for drawing: %@", drawingName);
    }
    return drawView;
}

+ (void)modifyDrawView:(BFWDrawView *)drawView
       withDerivedDict:(NSDictionary *)derivedDict
{
    NSString *tintColorString = derivedDict[tintColorKey]; //TODO: allow for "Tint Color" & "tintColor"
    if (tintColorString) {
        BFWStyleKit *styleKit = [BFWStyleKit styleKitForName:drawView.styleKit];
        drawView.tintColor = [styleKit colorForName:tintColorString];
    }
    NSString *sizeString = derivedDict[sizeKey];
    CGSize size = CGSizeFromString(sizeString);
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        drawView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    NSNumber *animationNumber = derivedDict[animationKey];
    if (animationNumber && [drawView isKindOfClass:[BFWAnimationView class]]) {
        BFWAnimationView *animationView = (BFWAnimationView *)drawView;
        animationView.animation = animationNumber.doubleValue;
        animationView.paused = YES; // so it only creates one image
    }
}

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        tintColor:(UIColor *)tintColor
                          android:(BOOL)isAndroid
                         duration:(CGFloat)duration
                  framesPerSecond:(CGFloat)framesPerSecond
{
    NSMutableSet *excludeFileNames = [[NSMutableSet alloc] init];
    for (NSString *styleKitName in styleKitArray) {
        BFWStyleKit *styleKit = [BFWStyleKit styleKitForName:styleKitName];
        NSDictionary *parameterDict = styleKit.parameterDict;
        NSArray *blacklist = styleKit.parameterDict[exportBlacklistKey];
        for (NSString *fileName in blacklist) {
            [excludeFileNames addObject:fileName.lowercaseWords];
        }
        for (BFWStyleKitDrawing *drawing in styleKit.drawings) {
            if (![drawing.methodParameters containsObject:@"frame"]) {
                // skipping since can't draw
                continue;
            }
            BFWDrawView *drawView = [self drawViewForName:drawing.name
                                                 styleKit:styleKitName
                                                tintColor:tintColor];
            [self writeImagesFromDrawView:drawView
                              toDirectory:directoryPath
                            pathScaleDict:pathScaleDict
                                 fileName:drawing.name
                                  android:isAndroid
                                 duration:duration
                          framesPerSecond:framesPerSecond
                         excludeFileNames:excludeFileNames];
        }
        for (NSString *drawingName in parameterDict[derivedKey]) {
            NSDictionary *derivedDict = parameterDict[derivedKey][drawingName];
            NSString *baseName = derivedDict[baseKey];
            BFWDrawView *drawView = [self drawViewForName:baseName
                                                 styleKit:styleKitName
                                                tintColor:tintColor];
            if ([drawingName containsString:@"%@"]) {
                NSString *arrayName = derivedDict[arrayKey];
                NSArray *array = parameterDict[arraysKey][arrayName];
                for (NSString *itemString in array) {
                    NSString *itemDrawingName = [NSString stringWithFormat:drawingName, itemString];
                    NSMutableDictionary *mutableDerivedDict = [derivedDict mutableCopy];
                    for (NSString *key in derivedDict) {
                        if ([key isEqualToString:arrayKey]) {
                            [mutableDerivedDict removeObjectForKey:key];
                        }
                        else {
                            NSString *format = derivedDict[key];
                            if ([format isKindOfClass:[NSString class]] && [format containsString:@"%@"]) {
                                mutableDerivedDict[key] = [NSString stringWithFormat:format, itemString];
                            }
                        }
                    }
                    [self modifyDrawView:drawView
                         withDerivedDict:[mutableDerivedDict copy]];
                    [self writeImagesFromDrawView:drawView
                                      toDirectory:directoryPath
                                    pathScaleDict:pathScaleDict
                                         fileName:itemDrawingName
                                          android:isAndroid
                                         duration:duration
                                  framesPerSecond:framesPerSecond
                                 excludeFileNames:excludeFileNames];
                }
            }
            else {
                [self modifyDrawView:drawView
                     withDerivedDict:derivedDict];
                [self writeImagesFromDrawView:drawView
                                  toDirectory:directoryPath
                                pathScaleDict:pathScaleDict
                                     fileName:drawingName
                                      android:isAndroid
                                     duration:duration
                              framesPerSecond:framesPerSecond
                             excludeFileNames:excludeFileNames];
            }
        }
    }
}

+ (void)writeImagesFromDrawView:(BFWDrawView *)drawView
                    toDirectory:(NSString *)directoryPath
                  pathScaleDict:(NSDictionary *)pathScaleDict
                       fileName:(NSString *)fileName
                        android:(BOOL)isAndroid
                       duration:(CGFloat)duration
                framesPerSecond:(CGFloat)framesPerSecond
               excludeFileNames:(NSMutableSet *)excludeFileNames
{
    NSString *fileNameLowercaseWords = fileName.lowercaseWords;
    if ([excludeFileNames containsObject:fileNameLowercaseWords]) {
        DLog(@"skipping excluded or existing file: %@", fileNameLowercaseWords);
        return;
    }
    NSString *useFileName = isAndroid ? [fileName androidFileName] : fileName;
    for (NSString *path in pathScaleDict) {
        NSNumber *scaleNumber = pathScaleDict[path];
        CGFloat scale = [scaleNumber floatValue];
        NSString *relativePath;
        if ([path containsString:@"%@"]) {
            relativePath = [NSString stringWithFormat:path, useFileName];
        }
        else {
            relativePath = [path stringByAppendingPathComponent:useFileName];
        }
        NSString *filePath = [directoryPath stringByAppendingPathComponent:relativePath];
        filePath = [filePath stringByAppendingPathExtension:@"png"];
        BOOL success = NO;
        if ([drawView isKindOfClass:[BFWAnimationView class]]) {
            BFWAnimationView *animationView = (BFWAnimationView *)drawView;
            if (duration) {
                animationView.duration = duration;
            }
            animationView.framesPerSecond = framesPerSecond;
            success = [animationView writeImagesAtScale:scale
                                                 toFile:filePath];
        }
        else {
            success = [drawView writeImageAtScale:scale
                                           toFile:filePath];
        }
        if (success) {
            [excludeFileNames addObject:fileNameLowercaseWords];
        }
        else {
            NSLog(@"failed to write %@", relativePath);
        }
    }
}

+ (void)exportForAndroid:(BOOL)isAndroid
             toDirectory:(NSString *)directory
               styleKits:(NSArray *)styleKits
           pathScaleDict:(NSDictionary *)pathScaleDict
               tintColor:(UIColor *)tintColor
                duration:(CGFloat)duration
         framesPerSecond:(CGFloat)framesPerSecond
{
    DLog(@"writing images to %@", directory);
    [self writeAllImagesToDirectory:directory
                          styleKits:styleKits
                      pathScaleDict:pathScaleDict
                          tintColor:tintColor
                            android:isAndroid
                           duration:duration
                    framesPerSecond:framesPerSecond];
    if (isAndroid) {
        /// Note: currently exports colors only from the first styleKit
        NSString *styleKitName = styleKits.firstObject;
        BFWStyleKit *styleKit = [BFWStyleKit styleKitForName:styleKitName];
        NSString *colorsXmlString = [styleKit colorsXmlString];
        NSString *colorsFile = [directory stringByAppendingPathComponent:@"paintcode_colors.xml"];
        [colorsXmlString writeToFile:colorsFile
                          atomically:YES
                            encoding:NSStringEncodingConversionAllowLossy
                               error:nil];
    }
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    return documentsPath;
}

+ (void)exportForAndroidToDocumentsStyleKits:(NSArray *)styleKits
                               pathScaleDict:(NSDictionary *)pathScaleDict
                                   tintColor:(UIColor *)tintColor
                                    duration:(CGFloat)duration
                             framesPerSecond:(CGFloat)framesPerSecond
{
    NSString *directory = [[self documentsDirectoryPath] stringByAppendingPathComponent:@"android_drawables"];
    [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
    [self exportForAndroid:YES
               toDirectory:directory
                 styleKits:styleKits
             pathScaleDict:pathScaleDict
                 tintColor:tintColor
                  duration:duration
           framesPerSecond:framesPerSecond];
}

@end
