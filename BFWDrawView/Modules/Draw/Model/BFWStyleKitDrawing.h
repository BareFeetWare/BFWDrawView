//
//  BFWStyleKitDrawing.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFWStyleKit;

@interface BFWStyleKitDrawing : NSObject

extern NSString * const drawPrefix;

@property (nonatomic, weak, readonly) BFWStyleKit *styleKit;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray *methodParameters;
@property (nonatomic, copy, readonly) NSString *methodName;
@property (nonatomic, readonly) CGSize drawnSize;
@property (nonatomic, readonly) BOOL hasDrawnSize;
@property (nonatomic, readonly) CGRect intrinsicFrame;

- (instancetype)initWithStyleKit:(BFWStyleKit *)styleKit
                            name:(NSString *)name;

@end
