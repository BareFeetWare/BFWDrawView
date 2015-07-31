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

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *methodParameters;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, weak) BFWStyleKit *styleKit;
@property (nonatomic, readonly) CGSize drawnSize;
@property (nonatomic, readonly) BOOL hasDrawnSize;
@property (nonatomic, readonly) CGRect intrinsicFrame;

@end
