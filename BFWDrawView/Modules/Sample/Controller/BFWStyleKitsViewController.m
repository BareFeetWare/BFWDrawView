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

@property (nonatomic, readonly) NSDictionary *styleKits;
@property (nonatomic, strong) NSArray *styleKitNames;

@end

@implementation BFWStyleKitsViewController

#pragma mark - accessors

- (NSArray *)styleKitNames
{
    if (!_styleKitNames) {
        _styleKitNames = [self.styleKits.allKeys arrayOfStringsSortedCaseInsensitive];
    }
    return _styleKitNames;
}

- (NSDictionary *)styleKits
{
    return [BFWStyleKit styleKits];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.styleKits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    
    NSString *styleKitName = self.styleKitNames[indexPath.row];
    BFWStyleKit *styleKit = self.styleKits[styleKitName];
    cell.textLabel.text = styleKitName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu drawings, %lu colors", (unsigned long)styleKit.drawings.count, (unsigned long)styleKit.colors.count];
    
    return cell;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[BFWStyleKitViewController class]]) {
        BFWStyleKitViewController *destinationViewController = segue.destinationViewController;
        if ([sender isKindOfClass:[UITableViewCell class]])
        {
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *styleKitName = self.styleKitNames[indexPath.row];
            destinationViewController.styleKit = self.styleKits[styleKitName];
        }
    }
}

@end
