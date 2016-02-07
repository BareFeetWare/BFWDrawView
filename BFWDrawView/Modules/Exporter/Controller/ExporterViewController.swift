//
//  ExporterViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class ExporterViewController: UITableViewController, UITextFieldDelegate, StyleKitsDelegate, ChoicesDelegate {

    // MARK: - Public variables
    
    var exporter: Exporter?
    
    // MARK: - IBOutlets

    @IBOutlet var namingSegmentedControl: UISegmentedControl?
    @IBOutlet var resolutionsCell: UITableViewCell?
    @IBOutlet var directoryTextField: UITextField?
    @IBOutlet var includeAnimationsSwitch: UISwitch?
    @IBOutlet var durationTextField: UITextField?
    @IBOutlet var framesPerSecondTextField: UITextField?
    @IBOutlet var drawingsStyleKitsCell: UITableViewCell?
    @IBOutlet var colorsStyleKitsCell: UITableViewCell?

    // MARK: - Private constants

    private let androidTitle = "Android";

    // MARK: - Private variables

    private var resolutions: [String: Double]?
    
    private var drawingsStyleKitNames: [String]?

    private var colorsStyleKitNames: [String]?

    private var activeListCell: UITableViewCell?

    // MARK: - Model to View to Model

    private func readModelIntoView() {
        if let exporter = exporter {
            let isAndroidFirst = self.namingSegmentedControl?.titleForSegmentAtIndex(0) == androidTitle
            namingSegmentedControl?.selectedSegmentIndex = exporter.isAndroid == isAndroidFirst ? 0 : 1
            resolutions = exporter.resolutions ?? exporter.defaultResolutions
            directoryTextField?.text = exporter.exportDirectoryURL?.path
            directoryTextField?.placeholder = exporter.defaultDirectoryURL.path
            drawingsStyleKitNames = exporter.drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
            colorsStyleKitNames = exporter.colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
            updateListCells()
            includeAnimationsSwitch?.on = exporter.includeAnimations ?? false
            durationTextField?.text = exporter.duration == nil ? nil : String(exporter.duration)
            framesPerSecondTextField?.text = exporter.framesPerSecond == nil ? nil : String(exporter.framesPerSecond)
        }
    }
    
    private func updateListCells() {
        // TODO: Sort resolutions.
        resolutionsCell?.detailTextLabel?.text = resolutions?.values.map { String($0) + "x" }.joinWithSeparator(", ")
        drawingsStyleKitsCell?.detailTextLabel?.text = drawingsStyleKitNames?.joinWithSeparator(", ")
        colorsStyleKitsCell?.detailTextLabel?.text = colorsStyleKitNames?.joinWithSeparator(", ")
    }
    
    private func writeViewToModel() {
        if let exporter = exporter {
            if let selectedSegmentTitle = namingSegmentedControl?.titleForSegmentAtIndex(namingSegmentedControl!.selectedSegmentIndex) {
                exporter.isAndroid = selectedSegmentTitle == androidTitle
            }
            exporter.resolutions = resolutions
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
    
    private func resolutionChoices() -> [Choice] {
        var choices = [Choice]()
        if let defaultResolutions = exporter?.defaultResolutions {
            choices = defaultResolutions.map { (name, scale) -> Choice in
                Choice(
                    title: name,
                    detail: "\(scale)x",
                    value: scale,
                    chosen: resolutions?.keys.contains(name) ?? true
                )
                }.sort { (choice1, choice2) -> Bool in
                    (choice1.value as! Double) < (choice2.value as! Double)
            }
        }
        return choices
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
            activeListCell = cell
            styleKitsViewController.delegate = self
            switch activeListCell! {
            case drawingsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String]
            case colorsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String]
            default:
                break
            }
        } else if let choicesViewController = segue.destinationViewController as? ChoicesViewController,
            cell = sender as? UITableViewCell
        {
            activeListCell = cell
            choicesViewController.delegate = self
            choicesViewController.choices = resolutionChoices()
        }
    }
    
    // MARK: - List Delegates
    
    func styleKitsViewController(styleKitsViewController: StyleKitsViewController, didChangeNames names: [String]) {
        switch activeListCell! {
        case drawingsStyleKitsCell!:
            drawingsStyleKitNames = names
        case colorsStyleKitsCell!:
            colorsStyleKitNames = names
        default:
            break
        }
        updateListCells()
    }
    
    func choicesViewController(choicesViewController: ChoicesViewController, didChangeChoice choice: Choice) {
        if activeListCell == resolutionsCell {
            if choice.chosen {
                resolutions?[choice.title] = choice.value as? Double
            } else {
                resolutions?.removeValueForKey(choice.title)
            }
            updateListCells()
        }
    }
    
}
