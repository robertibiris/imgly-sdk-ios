//
//  IMGLYMainEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

// Options for configuring the IMGLYMainEditorViewController
@objc public class IMGLYMainEditorViewControllerOptions: NSObject {
    
    // MARK: UI
    
    ///  Defaults to 'Editor'
    public lazy var title: String? = NSLocalizedString("main-editor.title", tableName: nil, bundle: NSBundle(forClass: IMGLYMainEditorViewController.self), value: "", comment: "")
    
    ///  Defaults to black
    public lazy var backgroundColor: UIColor = UIColor.blackColor()
    
    /**
    A configuration block to configure the given cancel button item.
    Defaults to a 'Cancel' in the apps tintColor.
    */
    public lazy var cancelButtonConfigurationBlock: IMGLYBarButtonItemConfigurationClosure = { barButtonItem in
        let bundle = NSBundle(forClass: IMGLYMainEditorViewController.self)
        barButtonItem.title = NSLocalizedString("main-editor.button.magic", tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
    /**
    A configuration block to configure the given done button item.
    Defaults to a 'Done' in the apps tintColor.
    */
    public lazy var doneButtonConfigurationBlock: IMGLYBarButtonItemConfigurationClosure = { barButtonItem in
        let bundle = NSBundle(forClass: IMGLYMainEditorViewController.self)
        barButtonItem.title = NSLocalizedString("main-editor.button.magic", tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
    // MARK: Behaviour
    
    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public lazy var allowsPreviewImageZoom: Bool = true
    
    /// Specifies the actions available in the bottom drawer. Defaults to the
    /// IMGLYMainEditorActionsDataSource providing all editors.
    public var editorActionsDataSource: IMGLYMainEditorActionsDataSourceProtocol = IMGLYMainEditorActionsDataSource()
}

@objc public enum IMGLYEditorResult: Int {
    case Done
    case Cancel
}

@objc public enum IMGLYMainEditorActionType: Int {
    case Magic
    case Filter
    case Stickers
    case Orientation
    case Focus
    case Crop
    case Brightness
    case Contrast
    case Saturation
    case Text
}

public typealias IMGLYEditorCompletionBlock = (IMGLYEditorResult, UIImage?) -> Void

private let ButtonCollectionViewCellReuseIdentifier = "ButtonCollectionViewCell"
private let ButtonCollectionViewCellSize = CGSize(width: 66, height: 90)

public class IMGLYMainEditorViewController: IMGLYEditorViewController {
    
    // MARK: - Properties
    public var completionBlock: IMGLYEditorCompletionBlock?
    public var initialFilterType = IMGLYFilterType.None
    public var initialFilterIntensity = NSNumber(double: 0.75)
    public private(set) var fixedFilterStack = IMGLYFixedFilterStack()
    
    private let maxLowResolutionSideLength = CGFloat(1600)
    public var highResolutionImage: UIImage? {
        didSet {
            generateLowResolutionImage()
        }
    }
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.configuration.mainEditorViewControllerOptions.backgroundColor
        
        navigationItem.title = self.configuration.mainEditorViewControllerOptions.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelTapped:")
        
        configuration.mainEditorViewControllerOptions.cancelButtonConfigurationBlock(navigationItem.leftBarButtonItem!)
        configuration.mainEditorViewControllerOptions.doneButtonConfigurationBlock(navigationItem.rightBarButtonItem!)
        
        navigationController?.delegate = self
        
        fixedFilterStack.effectFilter = IMGLYInstanceFactory.effectFilterWithType(initialFilterType)
        fixedFilterStack.effectFilter.inputIntensity = initialFilterIntensity
        
        updatePreviewImage()
        configureMenuCollectionView()
    }
    
    // MARK: - Configuration
    
    private func configureMenuCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = ButtonCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(IMGLYButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCellReuseIdentifier)
        
        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - Helpers
    
    private func subEditorButtonPressed(actionType: IMGLYMainEditorActionType) {
        if (actionType == .Magic) {
            if !updating {
                fixedFilterStack.enhancementFilter.enabled = !fixedFilterStack.enhancementFilter.enabled
                updatePreviewImage()
                
            }
        } else {
            if let viewController = IMGLYInstanceFactory.viewControllerForEditorActionType(actionType, withFixedFilterStack: fixedFilterStack, configuration: configuration) {
                viewController.lowResolutionImage = lowResolutionImage
                viewController.previewImageView.image = previewImageView.image
                viewController.completionHandler = subEditorDidComplete
                
                showViewController(viewController, sender: self)
            }
        }
    }
    
    private func subEditorDidComplete(image: UIImage?, fixedFilterStack: IMGLYFixedFilterStack) {
        previewImageView.image = image
        self.fixedFilterStack = fixedFilterStack
    }
    
    private func generateLowResolutionImage() {
        if let highResolutionImage = self.highResolutionImage {
            if highResolutionImage.size.width > maxLowResolutionSideLength || highResolutionImage.size.height > maxLowResolutionSideLength  {
                let scale: CGFloat
                
                if(highResolutionImage.size.width > highResolutionImage.size.height) {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.width
                } else {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.height
                }
                
                let newWidth  = CGFloat(roundf(Float(highResolutionImage.size.width) * Float(scale)))
                let newHeight = CGFloat(roundf(Float(highResolutionImage.size.height) * Float(scale)))
                lowResolutionImage = highResolutionImage.imgly_normalizedImageOfSize(CGSize(width: newWidth, height: newHeight))
            } else {
                lowResolutionImage = highResolutionImage.imgly_normalizedImage
            }
        }
    }
    
    private func updatePreviewImage() {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(PhotoProcessorQueue) {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image = processedImage
                    self.updating = false
                }
            }
        }
    }
    
    // MARK: - EditorViewController
    
    override public func tappedDone(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            highResolutionImage = highResolutionImage?.imgly_normalizedImage
            var filteredHighResolutionImage: UIImage?
            
            if let highResolutionImage = self.highResolutionImage {
                sender?.enabled = false
                dispatch_async(PhotoProcessorQueue) {
                    filteredHighResolutionImage = IMGLYPhotoProcessor.processWithUIImage(highResolutionImage, filters: self.fixedFilterStack.activeFilters)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionBlock(.Done, filteredHighResolutionImage)
                        sender?.enabled = true
                    }
                }
            } else {
                completionBlock(.Done, filteredHighResolutionImage)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @objc private func cancelTapped(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            completionBlock(.Cancel, nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public override var enableZoomingInPreviewImage: Bool {
        return self.configuration.mainEditorViewControllerOptions.allowsPreviewImageZoom
    }
}

extension IMGLYMainEditorViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.configuration.mainEditorViewControllerOptions.editorActionsDataSource.actionCount()
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ButtonCollectionViewCellReuseIdentifier, forIndexPath: indexPath) 
        
        if let buttonCell = cell as? IMGLYButtonCollectionViewCell {
            let dataSource = self.configuration.mainEditorViewControllerOptions.editorActionsDataSource
            let action = dataSource.actionAtIndex(indexPath.item)
            buttonCell.textLabel.text = action.title
            buttonCell.imageView.image = action.image
        }
        
        return cell
    }
}

extension IMGLYMainEditorViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let action = self.configuration.mainEditorViewControllerOptions.editorActionsDataSource.actionAtIndex(indexPath.item)
        subEditorButtonPressed(action.editorType)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let action = self.configuration.mainEditorViewControllerOptions.editorActionsDataSource.actionAtIndex(indexPath.item)
        if (action.editorType == .Magic) {
            if let buttonCell = cell as? IMGLYButtonCollectionViewCell, let selectedImage = action.selectedImage {
                if (fixedFilterStack.enhancementFilter.enabled) {
                    buttonCell.imageView.image = selectedImage
                } else {
                    buttonCell.imageView.image = action.image
                }
            }
        }
    }
}

extension IMGLYMainEditorViewController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return IMGLYNavigationAnimationController()
    }
}
