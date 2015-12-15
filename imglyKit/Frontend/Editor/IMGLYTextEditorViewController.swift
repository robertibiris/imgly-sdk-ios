//
//  TextEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 17/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let FontSizeInTextField = CGFloat(20)
private let TextFieldHeight = CGFloat(40)
private let TextLabelInitialMargin = CGFloat(40)
private let MinimumFontSize = CGFloat(12.0)

public class IMGLYTextEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    private var textColor = UIColor.whiteColor()
    private var fontName = ""
    private var currentTextSize = CGFloat(0)
    private var maximumFontSize = CGFloat(0)
    private var panOffset = CGPointZero
    private var fontSizeAtPinchBegin = CGFloat(0)
    private var distanceAtPinchBegin = CGFloat(0)
    private var beganTwoFingerPitch = false
    private var draggedView: UILabel?
    
    public private(set) lazy var textColorSelectorView: IMGLYTextColorSelectorView = {
        let view = IMGLYTextColorSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.menuDelegate = self
        return view
        }()
    
    public private(set) lazy var textClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
        }()
    
    public private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = UIColor(white:0.0, alpha:0.5)
        textField.text = ""
        textField.textColor = self.textColor
        textField.clipsToBounds = false
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textField.returnKeyType = UIReturnKeyType.Done
        return textField
        }()
    
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        label.backgroundColor = UIColor(white:0.0, alpha:0.0)
        label.textColor = self.textColor
        label.textAlignment = NSTextAlignment.Center
        label.clipsToBounds = true
        label.userInteractionEnabled = true
        return label
        }()
    
    public private(set) lazy var fontSelectorContainerView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()
    
    public private(set) lazy var fontSelectorView: IMGLYFontSelectorView = {
        let selector = IMGLYFontSelectorView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.selectorDelegate = self
        return selector
    }()
    
    // MAKR: - Initializers
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("text-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        IMGLYInstanceFactory.fontImporter().importFonts()
        
        navigationItem.rightBarButtonItem?.enabled = false
        configureColorSelectorView()
        configureTextClipView()
        configureTextField()
        configureTextLabel()
        configureFontSelectorView()
        registerForKeyboardNotifications()
        configureGestureRecognizers()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textClipView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
    }
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        fixedFilterStack.textFilter.text = textLabel.text ?? ""
        fixedFilterStack.textFilter.color = textColor
        fixedFilterStack.textFilter.fontName = fontName
        fixedFilterStack.textFilter.frame = transformedTextFrame()
        print( fixedFilterStack.textFilter.frame)
        fixedFilterStack.textFilter.fontScaleFactor = currentTextSize / previewImageView.visibleImageFrame.size.height
        fixedFilterStack.textFilter.transform = textLabel.transform
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Configuration
    
    private func configureColorSelectorView() {
        bottomContainerView.addSubview(textColorSelectorView)

        let views = [
            "textColorSelectorView" : textColorSelectorView
        ]
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textColorSelectorView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textColorSelectorView]|", options: [], metrics: nil, views: views))
    }
    
    private func configureTextClipView() {
        view.addSubview(textClipView)
    }
    
    private func configureTextField() {
        view.addSubview(textField)
        textField.frame = CGRect(x: 0, y: view.bounds.size.height, width: view.bounds.size.width, height: TextFieldHeight)
    }
    
    private func configureTextLabel() {
        textClipView.addSubview(textLabel)
    }
    
    private func configureFontSelectorView() {
        view.addSubview(fontSelectorContainerView)
        fontSelectorContainerView.contentView.addSubview(fontSelectorView)
        
        let views = [
            "fontSelectorContainerView" : fontSelectorContainerView,
            "fontSelectorView" : fontSelectorView
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fontSelectorContainerView]|", options: [], metrics: nil, views: views))
        
        fontSelectorContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorView]|", options: [], metrics: nil, views: views))
        fontSelectorContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fontSelectorView]|", options: [], metrics: nil, views: views))
    }
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        textClipView.addGestureRecognizer(panGestureRecognizer)

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
        rotationGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        pinchGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        let translation = recognizer.translationInView(textClipView)
        
        switch recognizer.state {
        
        case .Began:
            draggedView = textClipView.hitTest(location, withEvent: nil) as? UILabel
            if let draggedView = draggedView {
                textClipView.bringSubviewToFront(draggedView)
            }
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            }
            recognizer.setTranslation(CGPointZero, inView: textClipView)
        case .Cancelled, .Ended:
            draggedView = nil
        default:
            break
        }
    }
    
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: textClipView)
            let point2 = recognizer.locationOfTouch(1, inView: textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale
            
            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = textClipView.hitTest(midpoint, withEvent: nil) as? UILabel
                }
                
                if let draggedView = draggedView {
                    textClipView.bringSubviewToFront(draggedView)
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformScale(draggedView.transform, scale, scale)
                }
                
                recognizer.scale = 1
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }
    
    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: textClipView)
            let point2 = recognizer.locationOfTouch(1, inView: textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let rotation = recognizer.rotation
            
            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = textClipView.hitTest(midpoint, withEvent: nil) as? UILabel
                }
                
                if let draggedView = draggedView {
                    textClipView.bringSubviewToFront(draggedView)
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformRotate(draggedView.transform, rotation)
                }
                
                recognizer.rotation = 0
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }
    
    // MARK: - Notification Handling
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        if let frameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = view.convertRect(frameValue.CGRectValue(), fromView: nil)
            textField.frame = CGRect(x: 0, y: view.frame.size.height - keyboardFrame.size.height - TextFieldHeight, width: view.frame.size.width, height: TextFieldHeight)
        }
    }
    
    // MARK: - Helpers
    
    private func hideTextField() {
        UIView.animateWithDuration(0.2) {
            self.textField.alpha = 0.0
        }
    }
    
    private func showTextLabel() {
        UIView.animateWithDuration(0.2) {
            self.textLabel.alpha = 1.0
        }
    }
    
    private func calculateInitialFontSize() {
        if let text = textLabel.text {
            currentTextSize = 1.0
            
            var size = CGSizeZero
            if !text.isEmpty {
                repeat {
                    currentTextSize += 1.0
                    let font = UIFont(name: fontName, size: currentTextSize)
                    size = text.sizeWithAttributes([ NSFontAttributeName: font as! AnyObject ])
                } while (size.width < (view.frame.size.width - TextLabelInitialMargin))
            }
        }
    }
    
    private func calculateMaximumFontSize() {
        var size = CGSizeZero
        
        if let text = textLabel.text {
            if !text.isEmpty {
                maximumFontSize = currentTextSize
                repeat {
                    maximumFontSize += 1.0
                    let font = UIFont(name: fontName, size: maximumFontSize)
                    size = text.sizeWithAttributes([ NSFontAttributeName: font as! AnyObject ])
                } while (size.width < self.view.frame.size.width)
            }
        }
    }
    
    private func setInitialTextLabelSize() {
        calculateInitialFontSize()
        calculateMaximumFontSize()
        
        textLabel.font = UIFont(name: fontName, size: currentTextSize)
        textLabel.sizeToFit()
        textLabel.frame.origin.x = TextLabelInitialMargin / 2.0 - textClipView.frame.origin.x
        textLabel.frame.origin.y = -textLabel.frame.size.height / 2.0 + textClipView.frame.height / 2.0
    }
    
    private func calculateNewFontSizeBasedOnDistanceBetweenPoint(point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let diffX = point1.x - point2.x
        let diffY = point1.y - point2.y
        return sqrt(diffX * diffX + diffY  * diffY)
    }
    
    private func updateTextLabelFrameForCurrentFont() {
        // resize and keep the text centered
        let frame = textLabel.frame
        textLabel.sizeToFit()
        
        let diffX = frame.size.width - textLabel.frame.size.width
        let diffY = frame.size.height - textLabel.frame.size.height
        textLabel.frame.origin.x += (diffX / 2.0)
        textLabel.frame.origin.y += (diffY / 2.0)
    }
    
    private func transformedTextFrame() -> CGRect {
        let cropRect = fixedFilterStack.textFilter.cropRect
        let completeSize = textClipView.bounds.size
        var position = CGPoint(x: textLabel.frame.origin.x / completeSize.width,
        y: textLabel.frame.origin.y / completeSize.height)
        position.x *= cropRect.width
        position.y *= cropRect.height
        position.x += cropRect.origin.x
        position.y += cropRect.origin.y
 
        var size = textLabel.frame.size
        size.width = size.width / textLabel.frame.size.width
        size.height = size.height / textLabel.frame.size.height
        
        return CGRect(origin: position, size: size)
    }
}

extension IMGLYTextEditorViewController: IMGLYTextColorSelectorViewDelegate {
    public func textColorSelectorView(selectorView: IMGLYTextColorSelectorView, didSelectColor color: UIColor) {
        textColor = color
        textField.textColor = color
        textLabel.textColor = color
    }
}

extension IMGLYTextEditorViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideTextField()
        textLabel.text = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        setInitialTextLabelSize()
        showTextLabel()
        navigationItem.rightBarButtonItem?.enabled = true
        return true
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension IMGLYTextEditorViewController: IMGLYFontSelectorViewDelegate {
    public func fontSelectorView(fontSelectorView: IMGLYFontSelectorView, didSelectFontWithName fontName: String) {
        fontSelectorContainerView.removeFromSuperview()
        self.fontName = fontName
        textField.font = UIFont(name: fontName, size: FontSizeInTextField)
        textField.becomeFirstResponder()
    }
}

extension IMGLYTextEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        
        return false
    }
}