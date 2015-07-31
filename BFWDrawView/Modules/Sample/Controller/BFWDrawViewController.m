//
//  BFWDrawViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWDrawViewController.h"
#import "BFWStyleKitDrawing.h"
#import "BFWAnimationView.h"
#import "BFWStyleKit.h"

@interface BFWDrawViewController ()

@property (weak, nonatomic) IBOutlet BFWAnimationView *drawView;

@end

@implementation BFWDrawViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.drawing.name;
    self.drawView.styleKit = self.drawing.styleKit.name;
    self.drawView.name = self.drawing.name;
}

@end
