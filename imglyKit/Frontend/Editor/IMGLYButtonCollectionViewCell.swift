//
//  IMGLYButtonCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYButtonCollectionViewCell: IMGLYImageCaptionCollectionViewCell {

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageSize = CGSize(width: 44, height: 44)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
