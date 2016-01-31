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
    
    var exportersRoot: ExportersRoot?
    var exporter: [String: AnyObject]?
    
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
    
    private struct Key {
        static let exportDirectoryURL = "exportDirectoryURL"
        static let includeAnimations = "includeAnimations"
        static let drawingsStyleKitNames = "drawingsStyleKitNames"
        static let colorsStyleKitNames = "colorsStyleKitNames"
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
    
    private lazy var drawingsStyleKitNames: [String]? = {
        return self.exporter?[Key.drawingsStyleKitNames] as? [String] ?? BFWStyleKit.styleKitNames() as? [String]
    }()

    private lazy var colorsStyleKitNames: [String]? = {
        return self.exporter?[Key.colorsStyleKitNames] as? [String] ?? BFWStyleKit.styleKitNames() as? [String]
    }()

    private var documentsURL = NSURL(fileURLWithPath: BFWDrawExport.documentsDirectoryPath(), isDirectory: true)
    
    private var defaultDirectoryURL: NSURL {
        return documentsURL.URLByAppendingPathComponent("android_drawables", isDirectory: true)
    }

    private var directoryURL: NSURL? {
        get {
            return exporter?[Key.exportDirectoryURL] as? NSURL
        }
        set {
            exporter?[Key.exportDirectoryURL] = newValue
        }
    }

    private var includeAnimations: Bool {
        get {
            return exporter?[Key.includeAnimations] as? Bool ?? false
        }
        set {
            exporter?[Key.includeAnimations] = newValue
        }
    }

    private var activeStyleKitsCell: UITableViewCell?

    // MARK - Actions

    @IBAction func export(sender: AnyObject) {
        view.endEditing(true)
        var duration = 0.0
        var framesPerSecond = 0.0 // 0.0 = do not include animations
        includeAnimations = includeAnimationsSwitch?.on ?? false
        if includeAnimations {
            if let durationString = durationTextField?.text ?? durationTextField?.placeholder {
                duration = Double(durationString) ?? 0.0
            }
            if let framesPerSecondString = self.framesPerSecondTextField?.text ?? self.framesPerSecondTextField?.placeholder {
                framesPerSecond = Double(framesPerSecondString) ?? 0.0
            }
        }
        var useDirectoryURL: NSURL?
        if let directoryText = directoryTextField?.text {
            directoryURL = NSURL(fileURLWithPath: directoryText, isDirectory: true)
            useDirectoryURL = directoryURL
        } else {
            useDirectoryURL = defaultDirectoryURL
        }
        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(useDirectoryURL!, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles) {
            contents.forEach { (url) in
                try! NSFileManager.defaultManager().removeItemAtURL(url)
            }
        }
        var isAndroid = true
        if let selectedSegmentTitle = namingSegmentedControl?.titleForSegmentAtIndex(namingSegmentedControl!.selectedSegmentIndex) {
            isAndroid = selectedSegmentTitle == androidTitle
        }
        exportersRoot?.saveExporters()
        BFWDrawExport.exportForAndroid(
            isAndroid,
            toDirectory: directoryURL?.path,
            drawingsStyleKitNames: drawingsStyleKitNames,
            colorsStyleKitNames: colorsStyleKitNames,
            pathScaleDict: pathScaleDict,
            tintColor: UIColor.blackColor(), // TODO: get color from UI
            duration: duration,
            framesPerSecond: framesPerSecond
            )
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
        directoryTextField?.placeholder = defaultDirectoryURL.path
        directoryTextField?.text = directoryURL?.path
        includeAnimationsSwitch?.on = includeAnimations
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        drawingsStyleKitsCell?.detailTextLabel?.text = drawingsStyleKitNames?.joinWithSeparator(", ")
        colorsStyleKitsCell?.detailTextLabel?.text = colorsStyleKitNames?.joinWithSeparator(", ")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let styleKitsViewController = segue.destinationViewController as? StyleKitsViewController,
            cell = sender as? UITableViewCell
        {
            activeStyleKitsCell = cell
            styleKitsViewController.delegate = self
            switch activeStyleKitsCell! {
            case drawingsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = drawingsStyleKitNames
            case colorsStyleKitsCell!:
                styleKitsViewController.selectedStyleKitNames = colorsStyleKitNames
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
    }
    
}
