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

    @IBOutlet var nameTextField: UITextField?
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

    private var resolutions: [String: Double]? {
        return exporter?.resolutions ?? exporter?.defaultResolutions
    }

    private var drawingsStyleKitNames: [String]? {
        return exporter?.drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
    }
    
    private var colorsStyleKitNames: [String]? {
        return exporter?.colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
    }

    private var activeListCell: UITableViewCell?

    // MARK: - Model to View

    private func readModelIntoView() {
        if let exporter = exporter {
            nameTextField?.text = exporter.name
            let isAndroidFirst = self.namingSegmentedControl?.titleForSegmentAtIndex(0) == androidTitle
            namingSegmentedControl?.selectedSegmentIndex = exporter.isAndroid == isAndroidFirst ? 0 : 1
            updateResolutionsCell()
            directoryTextField?.text = exporter.exportDirectoryURL?.path
            directoryTextField?.placeholder = exporter.defaultDirectoryURL.path
            updateStyleKitCells()
            includeAnimationsSwitch?.on = exporter.includeAnimations ?? false
            durationTextField?.text = exporter.duration == nil ? nil : String(exporter.duration)
            framesPerSecondTextField?.text = exporter.framesPerSecond == nil ? nil : String(exporter.framesPerSecond)
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
    
    private func updateResolutionsCell() {
        resolutionsCell?.detailTextLabel?.text = resolutions?.map { (name, scale) in
            (name: name, scale: scale)
            }.sort{ (tuple1, tuple2) -> Bool in
                tuple1.scale < tuple2.scale
            }.reduce("") { (string, tuple) -> String in
                let previous = string == "" ? "" : "\(string), "
                return previous + "\(tuple.scale)x"
        }
    }
    
    private func shortStringOfStyleKitNames(styleKitNames: [String]) -> String {
        let suffix = "StyleKit"
        let shortNames: [String] = styleKitNames.map { name -> String in
            name.hasSuffix(suffix) ? name[name.startIndex ..< name.endIndex.advancedBy(-suffix.characters.count)] : name
        }
        return shortNames.joinWithSeparator(", ")
    }
    
    private func updateStyleKitCells() {
        drawingsStyleKitsCell?.detailTextLabel?.text = shortStringOfStyleKitNames(drawingsStyleKitNames!)
        colorsStyleKitsCell?.detailTextLabel?.text = shortStringOfStyleKitNames(colorsStyleKitNames!)
    }
    
    // MARK: - View to Model

    private func writeViewToModel() {
        if let exporter = exporter {
            exporter.name = nameTextField?.text
            if let directoryURLString = directoryTextField?.text where directoryTextField?.text?.characters.count > 0 {
                exporter.exportDirectoryURL = NSURL(fileURLWithPath: directoryURLString, isDirectory: true)
            }
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

    @IBAction func didChangePlatformControl(sender: UISegmentedControl) {
        if let selectedSegmentTitle = namingSegmentedControl?.titleForSegmentAtIndex(namingSegmentedControl!.selectedSegmentIndex) {
            exporter?.isAndroid = selectedSegmentTitle == androidTitle
            updateResolutionsCell()
        }
    }
    
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
            exporter?.drawingsStyleKitNames = names
        case colorsStyleKitsCell!:
            exporter?.colorsStyleKitNames = names
        default:
            break
        }
        updateStyleKitCells()
    }
    
    func choicesViewController(choicesViewController: ChoicesViewController, didChangeChoice choice: Choice) {
        if activeListCell == resolutionsCell {
            if choice.chosen {
                exporter?.resolutions?[choice.title] = choice.value as? Double
            } else {
                exporter?.resolutions?.removeValueForKey(choice.title)
            }
            updateResolutionsCell()
        }
    }
    
}
