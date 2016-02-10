//
//  StyleKitViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class StyleKitViewController: UITableViewController {

    // MARK: - Public variables
    
    var styleKit: BFWStyleKit?
    
    // MARK: - Structs
    
    private struct CellIdentifier {
        static let drawing = "drawing"
        static let animation = "animation"
    }
    
    // MARK: - Private variables
    
    lazy private var drawingNames: [String] = {
        let drawingNames = self.styleKit?.drawingNames as! [String]
        return drawingNames.map{ drawingName in
            drawingName.lowercaseWords()
        }
    }()

    // MARK: - UIViewController
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = styleKit?.name
    }

    // MARK: - UITableViewController

    override func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return drawingNames.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let drawingName = drawingNames[indexPath.row]
        let drawing = styleKit?.drawingForName(drawingName)
        let methodParameters = drawing?.methodParameters as? [String]
        let isAnimation = methodParameters?.contains("animation") ?? false
        let cellIdentifier = isAnimation ? CellIdentifier.animation : CellIdentifier.drawing
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,
            forIndexPath: indexPath) as! DrawingCell
        cell.textLabel?.text = drawingName
        var detailComponents = methodParameters
        cell.drawView?.styleKit = styleKit?.name
        cell.drawView?.name = drawingName
        if let drawnSize = drawing?.drawnSize {
            if !CGSizeEqualToSize(drawnSize, CGSizeZero) {
                detailComponents?.append("size = {\(drawnSize.width), \(drawnSize.height)}")
            }
        }
        cell.detailTextLabel?.text = detailComponents?.joinWithSeparator(", ")
        return cell;
    }

    // MARK: - UIViewController

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let drawViewController = segue.destinationViewController as? BFWDrawViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPathForCell(cell)
        {
            let drawingName = drawingNames[indexPath.row]
            let drawing = styleKit?.drawingForName(drawingName)
            drawViewController.drawing = drawing
        }
    }
    
}
