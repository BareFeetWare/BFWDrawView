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
    
    fileprivate struct CellIdentifier {
        static let drawing = "drawing"
        static let animation = "animation"
    }
    
    // MARK: - Private variables
    
    lazy fileprivate var drawingNames: [String] = {
        let drawingNames = self.styleKit?.drawingNames as! [String]
        return drawingNames.map { drawingName in
            drawingName.lowercaseWords()
            }.sorted(by: <)
    }()

    // MARK: - UIViewController
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = styleKit?.name
    }

    // MARK: - UITableViewController

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return drawingNames.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let drawingName = drawingNames[indexPath.row]
        let drawing = styleKit?.drawing(forName: drawingName)
        let methodParameters = drawing?.methodParameters as? [String]
        let isAnimation = methodParameters?.contains("animation") ?? false
        let cellIdentifier = isAnimation ? CellIdentifier.animation : CellIdentifier.drawing
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
            for: indexPath) as! DrawingCell
        cell.textLabel?.text = drawingName
        var detailComponents = methodParameters
        cell.drawView?.styleKit = styleKit?.name
        cell.drawView?.name = drawingName
        if let drawnSize = drawing?.drawnSize {
            if !drawnSize.equalTo(CGSize.zero) {
                detailComponents?.append("size = {\(drawnSize.width), \(drawnSize.height)}")
            }
        }
        cell.detailTextLabel?.text = detailComponents?.joined(separator: ", ")
        return cell;
    }

    // MARK: - UIViewController

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        {
            let drawingName = drawingNames[indexPath.row]
            let drawing = styleKit?.drawing(forName: drawingName)
            if let drawViewController = segue.destination as? DrawingViewController {
                drawViewController.drawing = drawing
            } else if let animationCountViewController = segue.destination as? AnimationCountViewController {
                animationCountViewController.drawing = drawing
            }
        }
    }
    
}
