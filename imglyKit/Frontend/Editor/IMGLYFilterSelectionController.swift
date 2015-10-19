//
//  IMGLYFilterSelectionController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
private let FilterCollectionViewCellSize = CGSize(width: 60, height: 90)
private let FilterActivationDuration = NSTimeInterval(0.15)

private var FilterPreviews = [IMGLYFilterType : UIImage]()

public typealias IMGLYFilterTypeSelectedBlock = (IMGLYFilterType) -> (Void)
public typealias IMGLYFilterTypeActiveBlock = () -> (IMGLYFilterType?)

public class IMGLYFilterSelectionController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var selectedCellIndex: Int?
    public var selectedBlock: IMGLYFilterTypeSelectedBlock?
    public var activeFilterType: IMGLYFilterTypeActiveBlock?
    public var previewImage = UIImage(named: "nonePreview", inBundle: NSBundle(forClass: IMGLYFilterSelectionController.self), compatibleWithTraitCollection:nil)! {
        didSet {
            FilterPreviews = [IMGLYFilterType: UIImage]()
            collectionView?.reloadData()
        }
    }
    public var tickImage = UIImage(named: "icon_tick", inBundle: NSBundle(forClass: IMGLYFilterSelectionController.self), compatibleWithTraitCollection:nil)! {
        didSet {
            collectionView?.reloadData()
        }
    }
    public var font: UIFont?
    public var previewImageSize = CGSize(width: 56, height: 56)
    
    // MARK: - Initializers
    
    public init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = FilterCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7
        super.init(collectionViewLayout: flowLayout)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.registerClass(IMGLYFilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCellReuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFilterSelectionController {
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IMGLYInstanceFactory.availableFilterList.count
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilterCollectionViewCellReuseIdentifier, forIndexPath: indexPath) 
        
        if let filterCell = cell as? IMGLYFilterCollectionViewCell {
            let filterType = IMGLYInstanceFactory.availableFilterList[indexPath.item]
            let filter = IMGLYInstanceFactory.effectFilterWithType(filterType)
            
            filterCell.textLabel.text = filter.imgly_displayName
            if let font = font {
                filterCell.textLabel.font = font
            }
            filterCell.imageSize = previewImageSize
            
            filterCell.imageView.layer.cornerRadius = 3
            filterCell.imageView.clipsToBounds = true
            filterCell.imageView.contentMode = .ScaleToFill
            filterCell.imageView.image = nil
            filterCell.tickImageView.image = tickImage
            
            filterCell.hideTick()

            if let filterPreviewImage = FilterPreviews[filterType] {
                self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filter.filterType, forImage: filterPreviewImage)
                filterCell.activityIndicator.stopAnimating()
            } else {
                filterCell.activityIndicator.startAnimating()
                
                // Create filterPreviewImage
                dispatch_async(PhotoProcessorQueue) {
                    let filterPreviewImage = IMGLYPhotoProcessor.processWithUIImage(self.previewImage, filters: [filter])
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        FilterPreviews[filterType] = filterPreviewImage
                        if let filterCell = collectionView.cellForItemAtIndexPath(indexPath) as? IMGLYFilterCollectionViewCell {
                            self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filter.filterType, forImage: filterPreviewImage)
                            filterCell.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Helpers
    
    private func updateCell(cell: IMGLYFilterCollectionViewCell, atIndexPath indexPath: NSIndexPath, withFilterType filterType: IMGLYFilterType, forImage image: UIImage?) {
        cell.imageView.image = image
        
        if let activeFilterType = activeFilterType?() where activeFilterType == filterType {
            cell.showTick()
            selectedCellIndex = indexPath.item
        }
    }
}

extension IMGLYFilterSelectionController {
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let extendedCellRect = CGRectInset(layoutAttributes.frame, -60, 0)
            collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        }
        
        let filterType = IMGLYInstanceFactory.availableFilterList[indexPath.item]
        
        if selectedCellIndex == indexPath.item {
            selectedBlock?(filterType)
            return
        }
        
        // get cell of previously selected filter if visible
        if let selectedCellIndex = self.selectedCellIndex, let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selectedCellIndex, inSection: 0)) as? IMGLYFilterCollectionViewCell {
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.hideTick()
            })
        }
        
        selectedBlock?(filterType)
        
        // get cell of newly selected filter
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? IMGLYFilterCollectionViewCell {
            selectedCellIndex = indexPath.item
            
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.showTick()
            })
        }
    }
}
