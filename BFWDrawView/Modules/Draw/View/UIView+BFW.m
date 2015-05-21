//
//  UIView+BFW.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "UIView+BFW.h"

@implementation UIView (BFW)

- (void)applyShadow:(NSShadow *)shadow
{
    UIColor *shadowColor = (UIColor *)shadow.shadowColor;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowRadius = shadow.shadowBlurRadius;
    self.layer.shadowOffset = shadow.shadowOffset;
    self.layer.shadowOpacity = shadow ? 1.0 : 0.0;
    self.layer.masksToBounds = shadow ? NO : YES;
}

@end
