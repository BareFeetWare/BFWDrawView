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

@interface BFWAndroidExportViewController ()

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *exportSizeCells;
@property (weak, nonatomic) IBOutlet UITableViewCell *exportCell;

@end

static const NSUInteger styleKitsSection = 1;

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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:styleKitsSection];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSString *styleKit = cell.textLabel.text;
            if (styleKit.length) {
                [styleKits addObject:styleKit];
            }
        }
    }
    return [styleKits copy];
}

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.exportCell) {
        [BFWDrawExport exportForAndroidToDocumentsStyleKits:[self styleKits]
                                              pathScaleDict:[self pathScaleDict]
                                                  tintColor:[UIColor blackColor]]; // TODO: get color from UI
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
    [cell setSelected:NO animated:YES];
}

@end
