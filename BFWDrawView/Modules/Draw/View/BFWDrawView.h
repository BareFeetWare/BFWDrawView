//
//  BFWDrawView.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* Disable Debug logging for release builds */
#endif

#import <UIKit/UIKit.h>

@interface NSString (BFWDrawView)

- (NSString *)capitalizedFirstString; // only capitalizes first character in string

@end

IB_DESIGNABLE

@interface BFWDrawView : UIView

@property (nonatomic, copy) IBInspectable NSString* name;
@property (nonatomic, copy) IBInspectable NSString* styleKit;
@property (nonatomic, strong) IBInspectable UIColor* fillColor;

@property (nonatomic, assign) CGSize drawnSize;
@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) BOOL canDraw;

// for subclasses:

@property (nonatomic, readonly) Class styleKitClass;
@property (nonatomic, readonly) NSString *drawFrameSelectorString;
@property (nonatomic, readonly) CGRect drawFrame;
@property (nonatomic, strong) NSInvocation *drawInvocation;

- (NSInvocation *)drawInvocationForSelectorString:(NSString *)selectorString argumentPointers:(NSArray *)argumentPointers;

#pragma mark - image output methods

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        fillColor:(UIColor *)fillColor
                          android:(BOOL)isAndroid;

@end
