//
//  AnimationCountViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 26/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "AnimationCountViewController.h"
#import "BFWAnimationView.h"

@interface AnimationCountViewController () <UITextFieldDelegate>

@property (strong, nonatomic) BFWStyleKitDrawing *drawing;

@property (weak, nonatomic) IBOutlet BFWAnimationView *animationView;
@property (weak, nonatomic) IBOutlet UITextField *desiredFramesPerSecondTextField;
@property (weak, nonatomic) IBOutlet UILabel *drawnFramesPerSecondLabel;
@property (strong, nonatomic) NSDate *startDate;
@property (assign, nonatomic) NSUInteger startCount;
@property (strong, nonatomic) NSString *animationKeyPath;

@end

static double const defaultDesiredFramesPerSecond = 60.0;

@implementation AnimationCountViewController

#pragma mark - dealloc

- (void)dealloc
{
    [self stopObserving];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationView.drawing = self.drawing;
    self.animationView.framesPerSecond = defaultDesiredFramesPerSecond;
    self.desiredFramesPerSecondTextField.placeholder = [NSString stringWithFormat:@"%1.1f", defaultDesiredFramesPerSecond];
    [self startObserving];
}

#pragma mark - KVO

- (NSString *)animationKeyPath
{
    if (!_animationKeyPath) {
        _animationKeyPath = NSStringFromSelector(@selector(animation));
    }
    return _animationKeyPath;
}

- (void)startObserving
{
    [self.animationView addObserver:self
                         forKeyPath:self.animationKeyPath
                            options:0
                            context:nil];
}

- (void)stopObserving
{
    [self.animationView removeObserver:self
                            forKeyPath:self.animationKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:self.animationKeyPath]) {
        self.drawnFramesPerSecondLabel.text = [NSString stringWithFormat:@"%1.1f", round(self.animationView.drawnFramesPerSecond * 10.0) / 10.0];
    }
}

#pragma mark - UITextFieldDelegate

#pragma mark - actions

- (IBAction)restart:(id)sender
{
    [self.view endEditing:NO];
    self.animationView.framesPerSecond = self.desiredFramesPerSecondTextField.text.doubleValue ?: defaultDesiredFramesPerSecond;
    [self.animationView restart];
}

@end
