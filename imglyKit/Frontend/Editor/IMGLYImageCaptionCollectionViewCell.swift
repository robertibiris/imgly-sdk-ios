//
//  IMGLYImageCaptionCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYImageCaptionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .Center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(11)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        return label
        }()
    
    var imageSize = CGSizeZero {
        didSet {
            imageHeightConstraint?.constant = imageSize.height
            imageWidthConstraint?.constant = imageSize.width
        }
    }
    
    var imageCaptionMargin = CGFloat(0) {
        didSet {
            imageCaptionMarginConstraint?.constant = imageCaptionMargin
        }
    }
    
    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageCaptionMarginConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        configureViews()
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Helpers
    
    private func configureViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        
        let views = [
            "imageView" : imageView,
            "textLabel" : textLabel
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|[imageView]|",
            options: [],
            metrics: nil,
            views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-(>=0)-[textLabel]-(>=0)-|",
            options: [],
            metrics: nil,
            views: views))
        
        let imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
        let textLabelBottomConstraint = NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)
        let textLabelCenterConstraint = NSLayoutConstraint(item: textLabel, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0)
    
        imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageSize.height)
        imageWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageSize.width)
        imageCaptionMarginConstraint = NSLayoutConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: imageCaptionMargin)
        
        NSLayoutConstraint.activateConstraints([imageViewTopConstraint, textLabelBottomConstraint, textLabelCenterConstraint, imageHeightConstraint!, imageWidthConstraint!, imageCaptionMarginConstraint!])
    }
    
    // MARK: - UICollectionViewCell
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let width = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).width
        layoutAttributes.frame.size.width = width
        
        return layoutAttributes
    }
    
}