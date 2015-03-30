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
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *styleKitCells;
@property (weak, nonatomic) IBOutlet UITableViewCell *exportCell;

@end

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

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.exportCell) {
        for (UITableViewCell *cell in self.styleKitCells) {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                [BFWDrawExport exportForAndroidToDocumentsStyleKits:@[cell.textLabel.text]
                                                      pathScaleDict:[self pathScaleDict]];
            }
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
    [cell setSelected:NO animated:YES];
}

@end
