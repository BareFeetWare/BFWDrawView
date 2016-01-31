//
//  BFWAndroidExportViewController.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExportersRoot;

@interface BFWAndroidExportViewController : UITableViewController

@property (nonatomic, strong) ExportersRoot *exportersRoot;
@property (nonatomic, strong) NSMutableDictionary *exporter; // [String: AnyObject]

@end
