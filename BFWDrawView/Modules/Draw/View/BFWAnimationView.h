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

@property (nonatomic, assign) IBInspectable double animation; // fraction 0.0 to 1.0. Set internally but exposed for storyboard preview
@property (nonatomic, assign) IBInspectable double start; // fraction 0.0 to 1.0. Start of animation.
@property (nonatomic, assign) IBInspectable double end; // fraction 0.0 to 1.0. End of animation.
@property (nonatomic, assign) IBInspectable double duration; // default = 3 seconds
@property (nonatomic, assign) IBInspectable double cycles; // default 0 = infinite repetitions
@property (nonatomic, assign) IBInspectable BOOL paused;

@property (nonatomic, assign) CGFloat framesPerSecond;
@property (nonatomic, readonly) CGFloat drawnFramesPerSecond;

- (void)restart;
- (BOOL)writeImagesAtScale:(CGFloat)scale
                    toFile:(NSString *)filePath;

@end
