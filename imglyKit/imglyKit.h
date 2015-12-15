//
//  imglyKit.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 29/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double imglyKitVersionNumber;
FOUNDATION_EXPORT const unsigned char imglyKitVersionString[];

#import <imglyKit/LUTToNSDataConverter.h>

#pragma mark - IMGLYMainEditorViewController

// Bitmask for editor action selection in configuration
typedef NS_OPTIONS(NSInteger, IMGLYMainEditorActionOption) {
    IMGLYMainEditorActionOptionMagic = 1 << 0,
    IMGLYMainEditorActionOptionFilter = 1 << 1,
    IMGLYMainEditorActionOptionStickers = 1 << 2,
    IMGLYMainEditorActionOptionOrientation = 1 << 3,
    IMGLYMainEditorActionOptionFocus = 1 << 4,
    IMGLYMainEditorActionOptionCrop = 1 << 5,
    IMGLYMainEditorActionOptionBrightness = 1 << 6,
    IMGLYMainEditorActionOptionContrast = 1 << 7,
    IMGLYMainEditorActionOptionSaturation = 1 << 8,
    IMGLYMainEditorActionOptionText = 1 << 9,
};

// Bitmask for allowed camera positions
typedef NS_OPTIONS(NSInteger, IMGLYCameraPosition) {
    IMGLYCameraPositionBack =  1 << 0,
    IMGLYCameraPositionFront = 1 << 1
};

// Bitmask for allowed flash types
typedef NS_OPTIONS(NSInteger, IMGLYFlashMode) {
    IMGLYFlashModeOff = 1 << 0,
    IMGLYFlashModeOn = 1 << 1,
    IMGLYFlashModeAuto = 1 << 2
};

// Bitmask for allowed torch types
typedef NS_OPTIONS(NSInteger, IMGLYTorchMode) {
    IMGLYTorchModeOff = 1 << 0,
    IMGLYTorchModeOn = 1 << 1,
    IMGLYTorchModeAuto = 1 << 2
};