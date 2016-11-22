//
//  AnimationCountViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 26/07/2015.
//  Copyright (c) 2015 BareFeetWare.
//

import UIKit

class AnimationCountViewController: UIViewController {
    
    // MARK: - Variables
    
    var drawing: BFWStyleKitDrawing!
    
    @IBOutlet var animationView: BFWAnimationView!
    @IBOutlet var desiredFramesPerSecondTextField: UITextField?
    @IBOutlet var drawnFramesPerSecondLabel: UILabel?
    
    lazy var animationKeyPath: String = {
        #keyPath(AnimationView.animation)
    }()
    
    struct Default {
        static let desiredFramesPerSecond: CGFloat = 60.0
    }
    
    // MARK: - Init
    
    deinit {
        stopObserving()
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView?.drawing = drawing
        animationView?.framesPerSecond = Default.desiredFramesPerSecond
        desiredFramesPerSecondTextField?.placeholder = String(format: "%1.1f", Default.desiredFramesPerSecond)
        startObserving()
    }
    
    // MARK: - KVO
    
    fileprivate func startObserving() {
        animationView.addObserver(self,
                                  forKeyPath: animationKeyPath,
                                  options: [],
                                  context: nil)
    }
    
    fileprivate func stopObserving() {
        animationView.removeObserver(self,
                                     forKeyPath: animationKeyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath == animationKeyPath {
            drawnFramesPerSecondLabel?.text = String(format: "%1.1f", round(animationView.drawnFramesPerSecond * 10.0) / 10.0)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func restart(_ sender: UIButton) {
        view.endEditing(false)
        animationView.framesPerSecond = desiredFramesPerSecondTextField?.text.flatMap { Double($0) }.flatMap { CGFloat($0) } ?? Default.desiredFramesPerSecond
        animationView.restart()
    }
    
}
