//
//  ExporterViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 29/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class ExporterViewController: UITableViewController {

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

    fileprivate let androidTitle = "Android";

    // MARK: - Private variables

    fileprivate var resolutions: [String: Double]? {
        return exporter?.resolutions ?? exporter?.defaultResolutions
    }

    fileprivate var drawingsStyleKitNames: [String]? {
        return exporter?.drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
    }
    
    fileprivate var colorsStyleKitNames: [String]? {
        return exporter?.colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as? [String]
    }

    fileprivate var activeListCell: UITableViewCell?

    // MARK: - Model to View

    fileprivate func readModelIntoView() {
        if let exporter = exporter {
            nameTextField?.text = exporter.name
            let isAndroidFirst = self.namingSegmentedControl?.titleForSegment(at: 0) == androidTitle
            namingSegmentedControl?.selectedSegmentIndex = exporter.isAndroid == isAndroidFirst ? 0 : 1
            updateResolutionsCell()
            directoryTextField?.text = exporter.exportDirectoryURL?.path
            directoryTextField?.placeholder = exporter.defaultDirectoryURL.path
            updateStyleKitCells()
            includeAnimationsSwitch?.isOn = exporter.includeAnimations ?? false
            durationTextField?.text = exporter.duration == nil ? nil : String(describing: exporter.duration)
            framesPerSecondTextField?.text = exporter.framesPerSecond == nil ? nil : String(describing: exporter.framesPerSecond)
        }
    }
    
    fileprivate func resolutionChoices() -> [Choice] {
        var choices = [Choice]()
        if let defaultResolutions = exporter?.defaultResolutions {
            choices = defaultResolutions.map { (name, scale) -> Choice in
                Choice(
                    title: name,
                    detail: "\(scale)x",
                    value: scale as AnyObject,
                    chosen: resolutions?.keys.contains(name) ?? true
                )
                }.sorted { (choice1, choice2) -> Bool in
                    (choice1.value as! Double) < (choice2.value as! Double)
            }
        }
        return choices
    }
    
    fileprivate func updateResolutionsCell() {
        resolutionsCell?.detailTextLabel?.text = resolutions?.map { (name, scale) in
            (name: name, scale: scale)
            }.sorted{ (tuple1, tuple2) -> Bool in
                tuple1.scale < tuple2.scale
            }.reduce("") { (string, tuple) -> String in
                let previous = string == "" ? "" : "\(string), "
                return previous + "\(tuple.scale)x"
        }
    }
    
    fileprivate func shortString(of styleKitNames: [String]) -> String {
        let suffix = "StyleKit"
        let shortNames: [String] = styleKitNames.map { name -> String in
            name.hasSuffix(suffix) ? name[name.startIndex ..< name.characters.index(name.endIndex, offsetBy: -suffix.characters.count)] : name
        }
        return shortNames.joined(separator: ", ")
    }
    
    fileprivate func updateStyleKitCells() {
        drawingsStyleKitsCell?.detailTextLabel?.text = shortString(of: drawingsStyleKitNames!)
        colorsStyleKitsCell?.detailTextLabel?.text = shortString(of: colorsStyleKitNames!)
    }
    
    // MARK: - View to Model

    fileprivate func writeViewToModel() {
        if let exporter = exporter {
            exporter.name = nameTextField?.text
            if let directoryURLString = directoryTextField?.text,
                !directoryURLString.isEmpty
            {
                exporter.exportDirectoryURL = URL(fileURLWithPath: directoryURLString, isDirectory: true)
            }
            exporter.includeAnimations = includeAnimationsSwitch?.isOn
            if let durationText = durationTextField?.text,
                let duration = TimeInterval(durationText)
            {
                exporter.duration = duration
            }
            if let framesPerSecondText = framesPerSecondTextField?.text,
                let framesPerSecond = Double(framesPerSecondText)
            {
                exporter.framesPerSecond = framesPerSecond
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func didChangePlatformControl(_ sender: UISegmentedControl) {
        if let selectedSegmentTitle = namingSegmentedControl?.titleForSegment(at: namingSegmentedControl!.selectedSegmentIndex) {
            exporter?.isAndroid = selectedSegmentTitle == androidTitle
            updateResolutionsCell()
        }
    }
    
    @IBAction func export(_ sender: AnyObject) {
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let styleKitsViewController = segue.destination as? StyleKitsViewController,
            let cell = sender as? UITableViewCell
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
        } else if let choicesViewController = segue.destination as? ChoicesViewController,
            let cell = sender as? UITableViewCell
        {
            activeListCell = cell
            choicesViewController.delegate = self
            choicesViewController.choices = resolutionChoices()
        }
    }
    
}

extension ExporterViewController: UITextFieldDelegate {

}

extension ExporterViewController: StyleKitsDelegate {
    func styleKitsViewController(_ styleKitsViewController: StyleKitsViewController, didChange names: [String]) {
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
}

extension ExporterViewController: ChoicesDelegate {
    func choicesViewController(_ choicesViewController: ChoicesViewController, didChange choice: Choice) {
        if activeListCell == resolutionsCell {
            if choice.chosen {
                exporter?.resolutions?[choice.title] = choice.value as? Double
            } else {
                let _ = exporter?.resolutions?.removeValue(forKey: choice.title)
            }
            updateResolutionsCell()
        }
    }
}
