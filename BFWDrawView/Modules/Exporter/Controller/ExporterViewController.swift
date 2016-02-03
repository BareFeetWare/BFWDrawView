//
//  ExporterViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class ExporterViewController: UITableViewController, UITextFieldDelegate, StyleKitsDelegate {

    // MARK: - Public variables
    
    var exporter: Exporter?
    
    // MARK: - IBOutlets

    @IBOutlet var namingSegmentedControl: UISegmentedControl?
    @IBOutlet var exportSizeCells: [UITableViewCell]?
    @IBOutlet var directoryTextField: UITextField?
    @IBOutlet var includeAnimationsSwitch: UISwitch?
    @IBOutlet var durationTextField: UITextField?
    @IBOutlet var framesPerSecondTextField: UITextField?
    @IBOutlet var drawingsStyleKitsCell: UITableViewCell?
    @IBOutlet var colorsStyleKitsCell: UITableViewCell?

    // MARK: - Private constants

    private enum Section: Int {
        case Sizes = 1
    }
    
    private let androidTitle = "Android";

    // MARK: - Private variables

    private var pathScaleDict: [String: Double] {
        var pathScaleDict = [String: Double]()
        for cell in exportSizeCells! {
            if cell.accessoryType == .Checkmark {
                if let path = cell.textLabel?.text,
                    text = cell.detailTextLabel?.text,
                    scale = Double(text)
                {
                    pathScaleDict[path] = scale;
                }
            }
        }
        return pathScaleDict
    }
    
    private var drawingsStyleKitNames: [String]?

    private var colorsStyleKitNames: [String]?

    private var activeStyleKitsCell: UITableViewCell?

    // MARK: - Model to View to Model

    private func readModelIntoView() {
        if let exporter = exporter {
            let isAndroidFirst = self.namingSegmentedControl?.titleForSegmentAtIndex(0) == androidTitle
            self.namingSegmentedControl?.selectedSegmentIndex = exporter.isAndroid == isAndroidFirst ? 0 : 1
            // TODO: pathToScaleDict
            directoryTextField?.text = exporter.exportDirectoryURL?.path
            directoryTextField?.placeholder = exporter.defaultDirectoryURL.path
            drawingsStyleKitNames = exporter.drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
            colorsStyleKitNames = exporter.colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
            updateStyleKitsCells()
            includeAnimationsSwitch?.on = exporter.includeAnimations ?? false
            durationTextField?.text = exporter.duration == nil ? nil : String(exporter.duration)
            framesPerSecondTextField?.text = exporter.framesPerSecond == nil ? nil : String(exporter.framesPerSecond)
        }
    }
    
    private func updateStyleKitsCells() {
        drawingsStyleKitsCell?.detailTextLabel?.text = drawingsStyleKitNames?.joinWithSeparator(", ")
        colorsStyleKitsCell?.detailTextLabel?.text = colorsStyleKitNames?.joinWithSeparator(", ")
    }
    
    private func writeViewToModel() {
        if let exporter = exporter {
            if let selectedSegmentTitle = namingSegmentedControl?.titleForSegmentAtIndex(namingSegmentedControl!.selectedSegmentIndex) {
                exporter.isAndroid = selectedSegmentTitle == androidTitle
            }
            exporter.pathScaleDict = pathScaleDict
            if let directoryURLString = directoryTextField?.text where directoryTextField?.text?.characters.count > 0 {
                exporter.exportDirectoryURL = NSURL(fileURLWithPath: directoryURLString, isDirectory: true)
            }
            exporter.drawingsStyleKitNames = drawingsStyleKitNames
            exporter.colorsStyleKitNames = colorsStyleKitNames
            exporter.includeAnimations = includeAnimationsSwitch?.on
            if let durationText = durationTextField?.text, duration = NSTimeInterval(durationText) {
                exporter.duration = duration
            }
            if let framesPerSecondText = framesPerSecondTextField?.text, framesPerSecond = Double(framesPerSecondText) {
                exporter.framesPerSecond = framesPerSecond
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func export(sender: AnyObject) {
        view.endEditing(true)
        writeViewToModel()
        exporter?.root.saveExporters()
        exporter?.export()
        let alertView = UIAlertView(
            title: "Export complete",
            message: "",
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alertView.show()
    }

    // MARK - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        readModelIntoView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let styleKitsViewController = segue.destinationViewController as? StyleKitsViewController,
            cell = sender as? UITableViewCell
        {
            activeStyleKitsCell = cell
            styleKitsViewController.delegate = self
            switch activeStyleKitsCell! {
            case drawingsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String]
            case colorsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String]
            default:
                break
            }
        }
    }

    // MARK - UITableViewController

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if indexPath.section == Section.Sizes.rawValue {
                let wasSelected = cell.accessoryType == .Checkmark
                let isSelected = !wasSelected
                cell.accessoryType = isSelected ? .Checkmark : .None
            }
            cell.setSelected(false, animated: true)
        }
    }

    // MARK: - StyleKitsDelegate
    
    func styleKitsViewController(styleKitsViewController: StyleKitsViewController, didChangeNames names: [String]) {
        switch activeStyleKitsCell! {
        case drawingsStyleKitsCell!:
            drawingsStyleKitNames = names
        case colorsStyleKitsCell!:
            colorsStyleKitNames = names
        default:
            break
        }
        updateStyleKitsCells()
    }
    
}
