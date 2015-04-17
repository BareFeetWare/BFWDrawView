//
//  BFWDrawExport.h
//
//  Created by Tom Brodhurst-Hill on 23/03/2015.
//  Copyright (c) 2015 CommBank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFWDrawExport : NSObject

#pragma mark - image output methods

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        tintColor:(UIColor *)tintColor
                          android:(BOOL)isAndroid;

+ (void)exportForAndroidToDirectory:(NSString *)directory
                          styleKits:(NSArray *)styleKits
                      pathScaleDict:(NSDictionary *)pathScaleDict
                          tintColor:(UIColor *)tintColor;

+ (void)exportForAndroidToDocumentsStyleKits:(NSArray *)styleKits
                               pathScaleDict:(NSDictionary *)pathScaleDict
                                   tintColor:(UIColor *)tintColor;

@end
