//
//  DrawingViewController.m
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

class DrawingViewController: UIViewController {

    var drawing: Drawing?
    
    @IBOutlet fileprivate var drawingView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = drawing?.name
        drawingView?.drawing = drawing
    }
    
}
