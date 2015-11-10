//
//  BFWAndroidExportViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWAndroidExportViewController.h"
#import "BFWDrawExport.h"
#import "NSObject+BFWStyleKit.h"

@interface BFWAndroidExportViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *exportSizeCells;
@property (weak, nonatomic) IBOutlet UITableViewCell *exportCell;
@property (weak, nonatomic) IBOutlet UITextField *directoryTextField;
@property (weak, nonatomic) IBOutlet UISwitch *includeAnimationsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *framesPerSecondTextField;

@property (nonatomic) NSString* directoryPath;
@property (nonatomic) BOOL includeAnimations;

@end

static NSUInteger const sizesSection = 0;
static NSUInteger const styleKitsSection = 1;
static NSString * const exportDirectoryBaseKey = @"exportDirectory";
static NSString * const includeAnimationsKey = @"includeAnimations";

@implementation BFWAndroidExportViewController

#pragma mark - accessors

- (NSDictionary *)pathScaleDict
{
    NSMutableDictionary *pathScaleDict = [[NSMutableDictionary alloc] init];
    for (UITableViewCell *cell in self.exportSizeCells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSString *path = cell.textLabel.text;
            NSNumber *scale = @(cell.detailTextLabel.text.doubleValue);
            if (path && scale) {
                pathScaleDict[path] = scale;
            }
        }
    }
    return [pathScaleDict copy];
}

- (NSArray *)styleKits
{
    NSMutableArray *styleKits = [[NSMutableArray alloc] init];
    NSUInteger cellCount = [self.tableView numberOfRowsInSection:styleKitsSection];
    for (NSUInteger row = 0; row < cellCount; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                    inSection:styleKitsSection];
        // Note: if we used [self.tableView cellForRowAtIndexPath:] then we would get nil if the cell was scrolled off screen. So, we ask the UITableViewController which keeps a reference to static cells that were created in the storyboard.
        UITableViewCell *cell = [self tableView:self.tableView
                          cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSString *styleKit = cell.textLabel.text;
            if (styleKit.length) {
                [styleKits addObject:styleKit];
            }
        }
    }
    return [styleKits copy];
}

- (NSString *)defaultDirectoryPath
{
    return [[BFWDrawExport documentsDirectoryPath] stringByAppendingPathComponent:@"android_drawables"];
}

- (NSString *)exportDirectoryKey {
    return [exportDirectoryBaseKey stringByAppendingPathComponent:self.navigationItem.title];
}
- (NSString *)directoryPath
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:self.exportDirectoryKey];
}

- (void)setDirectoryPath:(NSString *)directoryPath
{
    [[NSUserDefaults standardUserDefaults] setObject:directoryPath
                                              forKey:self.exportDirectoryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)includeAnimations
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:includeAnimationsKey];
}

- (void)setIncludeAnimations:(BOOL)includeAnimations
{
    [[NSUserDefaults standardUserDefaults] setBool:includeAnimations
                                            forKey:includeAnimationsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - actions

- (IBAction)export:(id)sender
{
    [self.view endEditing:YES];
    CGFloat duration = 0.0;
    CGFloat framesPerSecond = 0.0; // 0.0 = do not include animations;
    self.includeAnimations = self.includeAnimationsSwitch.isOn;
    if (self.includeAnimationsSwitch.isOn) {
        NSString *durationString = self.durationTextField.text.length ? self.durationTextField.text : self.durationTextField.placeholder;
        duration = durationString.doubleValue;
        NSString *framesPerSecondString = self.framesPerSecondTextField.text.length ? self.framesPerSecondTextField.text : self.framesPerSecondTextField.placeholder;
        framesPerSecond = framesPerSecondString.doubleValue;
    }
    self.directoryPath = self.directoryTextField.text;
    NSString *directoryPath = self.directoryPath.length ? self.directoryPath : [self defaultDirectoryPath];
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    [BFWDrawExport exportForAndroidToDirectory:directoryPath
                                     styleKits:[self styleKits]
                                 pathScaleDict:[self pathScaleDict]
                                     tintColor:[UIColor blackColor] // TODO: get color from UI
                                      duration:duration
                               framesPerSecond:framesPerSecond];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Export complete"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.directoryTextField.placeholder = [self defaultDirectoryPath];
    self.directoryTextField.text = self.directoryPath;
    self.includeAnimationsSwitch.on = self.includeAnimations;
}

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.exportCell) {
        [self export:cell];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (indexPath.section == sizesSection || indexPath.section == styleKitsSection) {
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
    [cell setSelected:NO animated:YES];
}

@end
