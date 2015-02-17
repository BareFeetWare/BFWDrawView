//
//  BFWAnimationView.h
//
//  Created by Tom Brodhurst-Hill on 15/01/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawView.h"

IB_DESIGNABLE

@interface BFWAnimationView : BFWDrawView

@property (nonatomic, assign) IBInspectable CGFloat animation;
@property (nonatomic, assign) IBInspectable double duration; // default = 3 seconds
@property (nonatomic, assign) IBInspectable NSUInteger cycles; // 0 = infinite repetitions
@property (nonatomic, assign) IBInspectable BOOL paused;

@end
