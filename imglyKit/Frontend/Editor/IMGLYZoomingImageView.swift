//
//  IMGLYZoomingImageView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public enum IMGLYZoomingImageViewFittingMode {
    case Automatic
    case Width
    case Height
}

public class IMGLYZoomingImageView: UIScrollView {
    
    // MARK: - Properties
    
    public var fittingMode = IMGLYZoomingImageViewFittingMode.Automatic
    
    public var image: UIImage? {
        get {
            return imageView.image
        }
        
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            contentSize = imageView.frame.size
            initialZoomScaleWasSet = false
            setNeedsLayout()
        }
    }
    
    public let imageView = UIImageView()
    private var initialZoomScaleWasSet = false
    public lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
        }()
    
    public var visibleImageFrame: CGRect {
        var visibleImageFrame = bounds
        visibleImageFrame.intersectInPlace(imageView.frame)
        return visibleImageFrame
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(imageView)
        addGestureRecognizer(doubleTapGestureRecognizer)
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        maximumZoomScale = 2
        scrollsToTop = false
        decelerationRate = UIScrollViewDecelerationRateFast
        exclusiveTouch = true
        delegate = self
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.image != nil {
            if !initialZoomScaleWasSet {
                var contentOffset = CGPointZero
                
                switch (fittingMode) {
                case .Automatic:
                    minimumZoomScale = min(frame.size.width / imageView.bounds.size.width, frame.size.height / imageView.bounds.size.height)
                case .Width:
                    minimumZoomScale = frame.size.width / imageView.bounds.size.width
                    let imageViewHeight = imageView.bounds.size.height * minimumZoomScale
                    if imageViewHeight > frame.size.height {
                        // Center vertically
                        contentOffset = CGPoint(x: 0, y: (imageViewHeight - frame.size.height) / 2)
                    }
                case .Height:
                    minimumZoomScale = frame.size.height / imageView.bounds.size.height
                    let imageViewWidth = imageView.bounds.size.width * minimumZoomScale
                    if imageViewWidth > frame.size.width {
                        // Center horizontally
                        contentOffset = CGPoint(x: (imageViewWidth - frame.size.width) / 2, y: 0)
                    }
                }
                zoomScale = minimumZoomScale
                self.contentOffset = contentOffset
                initialZoomScaleWasSet = true
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func doubleTapped(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(imageView)
        
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            zoomToRect(CGRect(x: location.x, y: location.y, width: 1, height: 1), animated: true)
        }
    }
}

extension IMGLYZoomingImageView: UIScrollViewDelegate {
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((bounds.size.width - contentSize.width) * 0.5, 0)
        let offsetY = max((bounds.size.height - contentSize.height) * 0.5, 0)
        
        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX, y: contentSize.height * 0.5 + offsetY)
    }
}
