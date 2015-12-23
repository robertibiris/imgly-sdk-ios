//
//  IMGLYBleachedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBleachedFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Bleached")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYBleachedFilter: EffectFilterType {
    public var displayName: String {
        return "Bleached"
    }

    public var filterType: IMGLYFilterType {
        return .Bleached
    }
}
