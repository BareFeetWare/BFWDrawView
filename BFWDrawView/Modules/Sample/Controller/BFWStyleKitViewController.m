//
//  BFWStyleKitViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import "BFWStyleKitViewController.h"
#import "BFWStyleKit.h"
#import "BFWStyleKitDrawing.h"
#import "BFWDrawingCell.h"
#import "BFWDrawView.h"
#import "NSArray+BFW.h"
#import "BFWDrawViewController.h"

@interface BFWStyleKitViewController ()

@property (nonatomic, strong) NSArray *drawingNames;

@end

@implementation BFWStyleKitViewController

#pragma mark - accessors

- (NSArray *)drawingNames
{
    if (!_drawingNames) {
        _drawingNames = [self.styleKit.drawings.allKeys arrayOfStringsSortedCaseInsensitive];
    }
    return _drawingNames;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.styleKit.name;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.drawingNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *drawingName = self.drawingNames[indexPath.row];
    BFWStyleKitDrawing *drawing = self.styleKit.drawings[drawingName];
    BOOL isAnimation = [drawing.methodParameters containsObject:@"animation"];
    NSString *cellIdentifier = isAnimation ? @"animation" : @"drawing";
    
    BFWDrawingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = drawingName;
    NSMutableArray *detailComponents = [NSMutableArray arrayWithArray:drawing.methodParameters];
    cell.drawView.styleKit = self.styleKit.name;
    cell.drawView.name = drawingName;
    CGSize drawnSize = drawing.drawnSize;
    if (!CGSizeEqualToSize(drawnSize, CGSizeZero)) {
        [detailComponents addObject:[NSString stringWithFormat:@"size = {%1.1f, %1.1f}", drawnSize.width, drawnSize.height]];
    }
    cell.detailTextLabel.text = [detailComponents componentsJoinedByString:@", "];
    
    return cell;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[BFWDrawViewController class]]) {
        BFWDrawViewController *destinationViewController = (BFWDrawViewController *)segue.destinationViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *drawingName = self.drawingNames[indexPath.row];
            BFWStyleKitDrawing *drawing = self.styleKit.drawings[drawingName];
            destinationViewController.drawing = drawing;
        }
    }
}

@end
