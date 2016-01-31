//
//  BFWAndroidExportViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWAndroidExportViewController.h"
#import "BFWDrawExport.h"
#import "BFWDrawView-Swift.h" // For ExportersRoot.
#import "BFWStyleKit.h"
#import "BFWStyleKitsViewController.h"
#import "NSObject+BFWStyleKit.h"

@interface BFWAndroidExportViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *namingSegmentedControl;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *exportSizeCells;
@property (weak, nonatomic) IBOutlet UITextField *directoryTextField;
@property (weak, nonatomic) IBOutlet UISwitch *includeAnimationsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *framesPerSecondTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *drawingsStyleKitsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *colorsStyleKitsCell;
@property (strong, nonatomic) NSMutableArray *drawingsStyleKitNames;
@property (strong, nonatomic) NSMutableArray *colorsStyleKitNames;
@property (copy, nonatomic) NSString *directoryPath;
@property (assign, nonatomic) BOOL includeAnimations;

@end

static NSUInteger const sizesSection = 1;
static NSString * const exportDirectoryKey = @"exportDirectory";
static NSString * const includeAnimationsKey = @"includeAnimations";
static NSString * const drawingsStyleKitNamesKey = @"drawingsStyleKitNames";
static NSString * const colorsStyleKitNamesKey = @"colorsStyleKitNames";
static NSString * const androidTitle = @"Android";

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

- (NSMutableArray *)drawingsStyleKitNames
{
    if (!_drawingsStyleKitNames) {
        NSArray *drawingsStyleKitNames = self.exporter[drawingsStyleKitNamesKey];
        if (!drawingsStyleKitNames) {
            drawingsStyleKitNames = [BFWStyleKit styleKitNames];
        }
        _drawingsStyleKitNames = [drawingsStyleKitNames mutableCopy];
    }
    return _drawingsStyleKitNames;
}

- (NSMutableArray *)colorsStyleKitNames
{
    if (!_colorsStyleKitNames) {
        _colorsStyleKitNames = [[BFWStyleKit styleKitNames] mutableCopy];
    }
    return _colorsStyleKitNames;
}

- (NSString *)defaultDirectoryPath
{
    return [[BFWDrawExport documentsDirectoryPath] stringByAppendingPathComponent:@"android_drawables"];
}

- (NSString *)directoryPath
{
    return self.exporter[exportDirectoryKey];
}

- (void)setDirectoryPath:(NSString *)directoryPath
{
    self.exporter[exportDirectoryKey] = directoryPath;
}

- (BOOL)includeAnimations
{
    return [self.exporter[includeAnimationsKey] boolValue];
}

- (void)setIncludeAnimations:(BOOL)includeAnimations
{
    self.exporter[includeAnimationsKey] = @(includeAnimations);
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
    BOOL isAndroid = [[self.namingSegmentedControl titleForSegmentAtIndex:self.namingSegmentedControl.selectedSegmentIndex] isEqualToString:androidTitle];
    [self.exportersRoot saveExporters];
    [BFWDrawExport exportForAndroid:isAndroid
                        toDirectory:directoryPath
              drawingsStyleKitNames:self.drawingsStyleKitNames
                colorsStyleKitNames:self.colorsStyleKitNames
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.drawingsStyleKitsCell.detailTextLabel.text = [self.drawingsStyleKitNames componentsJoinedByString:@", "];
    self.colorsStyleKitsCell.detailTextLabel.text = [self.colorsStyleKitNames componentsJoinedByString:@", "];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[BFWStyleKitsViewController class]]) {
        BFWStyleKitsViewController *styleKitsViewController = (BFWStyleKitsViewController *)segue.destinationViewController;
        if (sender == self.drawingsStyleKitsCell) {
            styleKitsViewController.selectedStyleKitNames = self.drawingsStyleKitNames;
        } else if (sender == self.colorsStyleKitsCell) {
            styleKitsViewController.selectedStyleKitNames = self.colorsStyleKitNames;
        }
    }
}

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == sizesSection) {
        BOOL wasSelected = cell.accessoryType == UITableViewCellAccessoryCheckmark;
        BOOL isSelected = !wasSelected;
        cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    [cell setSelected:NO animated:YES];
}

@end
