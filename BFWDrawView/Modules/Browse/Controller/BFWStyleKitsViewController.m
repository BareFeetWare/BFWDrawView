//
//  BFWStyleKitsViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWStyleKitsViewController.h"
#import "BFWStyleKit.h"
#import "BFWStyleKitViewController.h"
#import "NSArray+BFW.h"

@interface BFWStyleKitsViewController ()

@property (nonatomic, copy) NSArray *styleKitNames;

@end

@implementation BFWStyleKitsViewController

#pragma mark - accessors

- (NSArray *)styleKitNames
{
    if (!_styleKitNames) {
        _styleKitNames = [[BFWStyleKit styleKitNames] arrayOfStringsSortedCaseInsensitive];
    }
    return _styleKitNames;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.styleKitNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    NSString *styleKitName = self.styleKitNames[indexPath.row];
    cell.textLabel.text = styleKitName;
    BFWStyleKit *styleKit = [BFWStyleKit styleKitForName:styleKitName];
    // TODO: Get drawingNames and colorNames on background thread since it is CPU expensive and pauses UI.
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu drawings, %lu colors", (unsigned long)styleKit.drawingNames.count, (unsigned long)styleKit.colorNames.count];
    
    return cell;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[BFWStyleKitViewController class]]) {
        BFWStyleKitViewController *destinationViewController = segue.destinationViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *styleKitName = self.styleKitNames[indexPath.row];
            destinationViewController.styleKit = [BFWStyleKit styleKitForName:styleKitName];
        }
    }
}

@end
