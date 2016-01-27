//
//  BFWAndroidExportViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWAndroidExportViewController.h"
#import "BFWDrawExport.h"
#import "BFWStyleKit.h"
#import "NSObject+BFWStyleKit.h"

@interface BFWAndroidExportViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *namingSegmentedControl;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *exportSizeCells;
@property (weak, nonatomic) IBOutlet UITextField *directoryTextField;
@property (weak, nonatomic) IBOutlet UISwitch *includeAnimationsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *framesPerSecondTextField;
@property (strong, nonatomic) UITableViewCell *styleKitCell;
@property (strong, nonatomic) NSMutableArray *chosenStyleKitNames;
@property (copy, nonatomic) NSString *directoryPath;
@property (assign, nonatomic) BOOL includeAnimations;

@end

static NSUInteger const sizesSection = 1;
static NSUInteger const styleKitsSection = 2;
static NSString * const styleKitCellReuseIdentifier = @"styleKit";
static NSString * const exportDirectoryBaseKey = @"exportDirectory";
static NSString * const includeAnimationsKey = @"includeAnimations";
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

- (NSMutableArray *)chosenStyleKitNames
{
    if (!_chosenStyleKitNames) {
        _chosenStyleKitNames = [[BFWStyleKit styleKitNames] mutableCopy];
    }
    return _chosenStyleKitNames;
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
    BOOL isAndroid = [[self.namingSegmentedControl titleForSegmentAtIndex:self.namingSegmentedControl.selectedSegmentIndex] isEqualToString:androidTitle];
    [BFWDrawExport exportForAndroid:isAndroid
                        toDirectory:directoryPath
                          styleKits:self.chosenStyleKitNames
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == styleKitsSection) {
        count = [BFWStyleKit styleKitNames].count;
    } else {
        count = [super tableView:tableView numberOfRowsInSection:section];
    }
    return count;
}

- (UITableViewCell *)styleKitCell
{
    if (!_styleKitCell) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                    inSection:styleKitsSection];
        _styleKitCell = [super tableView:self.tableView
                   cellForRowAtIndexPath:indexPath];
    }
    return _styleKitCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == styleKitsSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:styleKitCellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:styleKitCellReuseIdentifier];
        }
        NSString *styleKitName = [BFWStyleKit styleKitNames][indexPath.row];
        cell.textLabel.text = styleKitName;
        cell.accessoryType = [self.chosenStyleKitNames containsObject:styleKitName] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == sizesSection || indexPath.section == styleKitsSection) {
        BOOL wasSelected = cell.accessoryType == UITableViewCellAccessoryCheckmark;
        BOOL isSelected = !wasSelected;
        cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if (indexPath.section == styleKitsSection) {
            NSString *styleKitName = [BFWStyleKit styleKitNames][indexPath.row];
            if (isSelected) {
                if (![self.chosenStyleKitNames containsObject:styleKitName]) {
                    [self.chosenStyleKitNames addObject:styleKitName];
                }
            } else {
                [self.chosenStyleKitNames removeObject:styleKitName];
            }
        }
    }
    [cell setSelected:NO animated:YES];
}

@end
