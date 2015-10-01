//
//  IMGLYFilterCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYFilterCollectionViewCell: IMGLYImageCaptionCollectionViewCell {
    
    // MARK: - Properties
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()
    
    lazy var tickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .Center
        imageView.alpha = 0
        return imageView
        }()
    
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
    }
    
    // MARK: - Configuration
    func showTick() {
        tickImageView.alpha = 1
        imageView.alpha = 0.4
    }
    
    func hideTick() {
        tickImageView.alpha = 0
        imageView.alpha = 1
    }
    
    // MARK: - Helpers
    
    private func configureViews() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(tickImageView)
        
        contentView.addConstraint(NSLayoutConstraint(item: tickImageView, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: tickImageView, attribute: .Right, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: tickImageView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: tickImageView, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Left, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: imageView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    // MARK: - ImageCaptionCollectionViewCell
    
    override var imageSize: CGSize {
        return CGSize(width: 56, height: 56)
    }
    
    override var imageCaptionMargin: CGFloat {
        return 3
    }
}
