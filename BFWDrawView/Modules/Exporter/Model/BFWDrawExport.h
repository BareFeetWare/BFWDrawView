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
                         duration:(NSTimeInterval)duration
                  framesPerSecond:(double)framesPerSecond;

+ (void)exportForAndroid:(BOOL)isAndroid
             toDirectory:(NSString *)directory
     deleteExistingFiles:(BOOL)deleteExistingFiles
   drawingsStyleKitNames:(NSArray *)drawingsStyleKitNames
     colorsStyleKitNames:(NSArray *)colorsStyleKitNames
           pathScaleDict:(NSDictionary *)pathScaleDict
               tintColor:(UIColor *)tintColor
                duration:(NSTimeInterval)duration
         framesPerSecond:(double)framesPerSecond;

@end
