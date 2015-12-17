//
//  IMGLYOrientationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYOrientationAction: Int {
    case RotateLeft
    case RotateRight
    case FlipHorizontally
    case FlipVertically
}

@objc public class IMGLYOrientationEditorViewControllerOptions: IMGLYEditorViewControllerOptions {
    
    public typealias IMGLYOrientationActionButtonConfigurationClosure = (IMGLYImageCaptionButton, IMGLYOrientationAction) -> ()

    // MARK: Behaviour
    
    /// Defines all allowed actions. The action buttons are always shown in the rotate -> flip order.
    /// Defaults to show all available actions. To set this
    /// property from Obj-C, see the `allowedOrientationActionsAsNSNumbers` property.
    public var allowedOrientationActions: [IMGLYOrientationAction] = [ .RotateLeft, .RotateRight, .FlipHorizontally, .FlipVertically ]
    
    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: IMGLYOrientationActionButtonConfigurationClosure = { _ in }
    
    // MARK: Obj-C Compatibility
    
    /// An array of `IMGLYOrientationAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedOrientationActions` with the corresponding `IMGLYFocusAction` values.
    public var allowedOrientationActionsAsNSNumbers: [NSNumber] = [ IMGLYOrientationAction.RotateLeft, .RotateRight, .FlipHorizontally, .FlipVertically ].map({ NSNumber(integer: $0.rawValue) }) {
        didSet {
            self.allowedOrientationActions = allowedOrientationActionsAsNSNumbers.map({ IMGLYOrientationAction(rawValue: $0.integerValue)! })
        }
    }
    
    // MARK: Init
    
    public override init() {
        super.init()
        
        /// Override inherited properties with default values
        self.title = NSLocalizedString("orientation-editor.title", tableName: nil, bundle: NSBundle(forClass: IMGLYMainEditorViewController.self), value: "", comment: "")
    }
}

public class IMGLYOrientationEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public private(set) lazy var rotateLeftButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-left", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-l", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateLeft:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .RotateLeft)
        return button
        }()
    
    public private(set) lazy var rotateRightButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-right", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-r", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateRight:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .RotateRight)
        return button
        }()
    
    public private(set) lazy var flipHorizontallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-horizontally", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipHorizontally:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .FlipHorizontally)
        return button
        }()
    
    public private(set) lazy var flipVerticallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-vertically", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipVertically:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .FlipVertically)
        return button
        }()
    
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = options.title
        
        configureButtons()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
                updatePreviewImageWithoutCropWithCompletion {
                    self.view.layoutIfNeeded()
                }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - IMGLYEditorViewController
    
    public override var options: IMGLYOrientationEditorViewControllerOptions {
        return self.configuration.orientationEditorViewControllerOptions
    }
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Configuration
    
    private func configureButtons() {
        // Map actions and buttons
        let actionToButtonMap: [IMGLYOrientationAction: IMGLYImageCaptionButton] = [
            .RotateLeft: rotateLeftButton,
            .RotateRight: rotateRightButton,
            .FlipHorizontally: flipHorizontallyButton,
            .FlipVertically: flipVerticallyButton
        ]
        
        // Setup button container view
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: ["buttonContainerView": buttonContainerView]))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
        
        var views = [String: UIView]()
        var viewNames = [String]()
        for action in options.allowedOrientationActions {
            let button = actionToButtonMap[action]!
            let viewName = "_\(String(button.hash))" // View names must start with a letter or underscore
            viewNames.append(viewName)
            buttonContainerView.addSubview(button)
            views[viewName] = button
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))
        }
        
        // Button Constraints
        let visualFormatString = viewNames.reduce("") { (acc, name) -> String in
            return acc + "[\(name)(==buttonWidth)]"
        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 70 ], views: views))
    }
    
    // MARK: - Helpers
    
    private func updatePreviewImageWithoutCropWithCompletion(completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        updatePreviewImageWithCompletion { () -> (Void) in
            completionHandler?()
        }
    }
    
    // MARK: - Actions
    
    @objc private func rotateLeft(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateLeft()
        fixedFilterStack.rotateStickersLeft()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func rotateRight(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        fixedFilterStack.rotateStickersRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func flipHorizontally(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        fixedFilterStack.flipStickersHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
    
    @objc private func flipVertically(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        fixedFilterStack.flipStickersVertical()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
}
