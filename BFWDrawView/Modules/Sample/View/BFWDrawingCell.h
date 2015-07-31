//
//  BFWDrawingCell.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFWDrawView;

@interface BFWDrawingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (weak, nonatomic) IBOutlet BFWDrawView *drawView;

@end
