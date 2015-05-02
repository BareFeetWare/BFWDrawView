//
//  BFWDrawExport.h
//
//  Created by Tom Brodhurst-Hill on 23/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import <UIKit/UIKit.h>

@interface BFWDrawExport : NSObject

#pragma mark - image output methods

+ (NSString *)documentsDirectoryPath;

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        tintColor:(UIColor *)tintColor
                          android:(BOOL)isAndroid
                         duration:(CGFloat)duration
                  framesPerSecond:(CGFloat)framesPerSecond;

+ (void)exportForAndroidToDirectory:(NSString *)directory
                          styleKits:(NSArray *)styleKits
                      pathScaleDict:(NSDictionary *)pathScaleDict
                          tintColor:(UIColor *)tintColor
                           duration:(CGFloat)duration
                    framesPerSecond:(CGFloat)framesPerSecond;

+ (void)exportForAndroidToDocumentsStyleKits:(NSArray *)styleKits
                               pathScaleDict:(NSDictionary *)pathScaleDict
                                   tintColor:(UIColor *)tintColor
                                    duration:(CGFloat)duration
                             framesPerSecond:(CGFloat)framesPerSecond;

@end
