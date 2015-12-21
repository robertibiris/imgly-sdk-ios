//
//  IMGLYConfiguration.swift
//  imglyKit
//
//  Created by Malte Baumann on 25/11/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

public enum IMGLYConfigurationError: ErrorType {
    case ReplacingClassNotASubclass
}

/// This closure allows the configuration of the given barbutton item.
public typealias IMGLYBarButtonItemConfigurationClosure = (UIBarButtonItem) -> ()

/// This closure allows the configuration of the given button.
public typealias IMGLYButtonConfigurationClosure = (UIButton) -> ()

/// This closure allows the configuration of the given label.
public typealias IMGLYLabelConfigurationClosure = (UILabel) -> ()

/// This closure allows the configuration of the given slider.
public typealias IMGLYSliderConfigurationClosure = (UISlider) -> ()

/// This closure allows the configuration of the given text field.
public typealias IMGLYTextFieldConfigurationClosure = (UITextField) -> ()

/**
 An IMGLYConfiguration defines behaviour and look of all view controllers
 provided by the imglyKit. It uses the builder pattern to create an
 immutable object via a closure. To configure the different editors and
 viewControllers contained in the SDK, edit their options in the corresponding
 `configure*ViewController` method of the `IMGLYConfigurationBuilder`.
*/
@objc public class IMGLYConfiguration : NSObject {
    
    // MARK: Properties
    
    /// Defaults to black.
    public let backgroundColor: UIColor
    
    /// Camera View Controller
    public let cameraViewControllerOptions: IMGLYCameraViewControllerOptions
    
    // Editor View Controller options
    public let mainEditorViewControllerOptions: IMGLYMainEditorViewControllerOptions
    public let filterEditorViewControllerOptions: IMGLYFilterEditorViewControllerOptions
    public let stickersEditorViewControllerOptions: IMGLYStickersEditorViewControllerOptions
    public let orientationEditorViewControllerOptions: IMGLYOrientationEditorViewControllerOptions
    public let focusEditorViewControllerOptions: IMGLYFocusEditorViewControllerOptions
    public let cropEditorViewControllerOptions: IMGLYCropEditorViewControllerOptions
    public let brightnessEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions
    public let contrastEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions
    public let saturationEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions
    public let textEditorViewControllerOptions: IMGLYTextEditorViewControllerOptions
    
    //  MARK: Initialization
    
    override convenience init() {
        self.init(builder: { _ in })
    }
    
    public init(builder: (IMGLYConfigurationBuilder -> Void)) {
        let builderForClosure = IMGLYConfigurationBuilder()
        builder(builderForClosure)
        self.backgroundColor = builderForClosure.backgroundColor
        self.cameraViewControllerOptions = builderForClosure.cameraViewControllerOptions
        self.mainEditorViewControllerOptions = builderForClosure.mainEditorViewControllerOptions
        self.filterEditorViewControllerOptions = builderForClosure.filterEditorViewControllerOptions
        self.stickersEditorViewControllerOptions = builderForClosure.stickersEditorViewControllerOptions
        self.orientationEditorViewControllerOptions = builderForClosure.orientationEditorViewControllerOptions
        self.focusEditorViewControllerOptions = builderForClosure.focusEditorViewControllerOptions
        self.cropEditorViewControllerOptions = builderForClosure.cropEditorViewControllerOptions
        self.brightnessEditorViewControllerOptions = builderForClosure.brightnessEditorViewControllerOptions
        self.contrastEditorViewControllerOptions = builderForClosure.contrastEditorViewControllerOptions
        self.saturationEditorViewControllerOptions = builderForClosure.saturationEditorViewControllerOptions
        self.textEditorViewControllerOptions = builderForClosure.textEditorViewControllerOptions
        self.classReplacingMap = builderForClosure.classReplacingMap
        super.init()
    }
    
    /// Used internally to fetch a replacement class for framework classes.
    func getClassForReplacedClass(replacedClass: NSObject.Type) -> NSObject.Type {
        guard let replacingClassName = classReplacingMap[String(replacedClass)]
            else { return replacedClass }

        return NSClassFromString(replacingClassName) as! NSObject.Type
    }

    private let classReplacingMap: [String: String]
}

/**
 The configuration builder object offers all properties of `IMGLYConfiguration` in
 a mutable version, in order to build an immutable `IMGLYConfiguration` object. To
 further configure the different viewcontrollers, use the `configureXYZViewController`
 methods to edit the given options.
*/
@objc public class IMGLYConfigurationBuilder : NSObject {
    public var backgroundColor: UIColor = UIColor.blackColor()
    private var cameraViewControllerOptions: IMGLYCameraViewControllerOptions = IMGLYCameraViewControllerOptions()
    private var mainEditorViewControllerOptions: IMGLYMainEditorViewControllerOptions = IMGLYMainEditorViewControllerOptions()
    private var filterEditorViewControllerOptions: IMGLYFilterEditorViewControllerOptions = IMGLYFilterEditorViewControllerOptions()
    private var stickersEditorViewControllerOptions: IMGLYStickersEditorViewControllerOptions = IMGLYStickersEditorViewControllerOptions()
    private var orientationEditorViewControllerOptions: IMGLYOrientationEditorViewControllerOptions = IMGLYOrientationEditorViewControllerOptions()
    private var focusEditorViewControllerOptions: IMGLYFocusEditorViewControllerOptions = IMGLYFocusEditorViewControllerOptions()
    private var cropEditorViewControllerOptions: IMGLYCropEditorViewControllerOptions = IMGLYCropEditorViewControllerOptions()
    private var brightnessEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions()
    private var contrastEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions()
    private var saturationEditorViewControllerOptions: IMGLYSliderEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions()
    private var textEditorViewControllerOptions: IMGLYTextEditorViewControllerOptions = IMGLYTextEditorViewControllerOptions()
    
    public func configureCameraViewController(builder: (IMGLYCameraViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYCameraViewControllerOptionsBuilder()
        builder(builderForClosure)
        cameraViewControllerOptions = IMGLYCameraViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureMainEditorViewController(builder: (IMGLYMainEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYMainEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        mainEditorViewControllerOptions = IMGLYMainEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureFilterEditorViewController(builder: (IMGLYFilterEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYFilterEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        filterEditorViewControllerOptions = IMGLYFilterEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureStickersEditorViewController(builder: (IMGLYStickersEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYStickersEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        stickersEditorViewControllerOptions = IMGLYStickersEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureOrientationEditorViewController(builder: (IMGLYOrientationEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYOrientationEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        orientationEditorViewControllerOptions = IMGLYOrientationEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureFocusEditorViewController(builder: (IMGLYFocusEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYFocusEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        focusEditorViewControllerOptions = IMGLYFocusEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureCropEditorViewController(builder: (IMGLYCropEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYCropEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        cropEditorViewControllerOptions = IMGLYCropEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureBrightnessEditorViewController(builder: (IMGLYSliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYSliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        brightnessEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureSaturationEditorViewController(builder: (IMGLYSliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYSliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        saturationEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions(builder: builderForClosure)
    }
    
    public func configureContrastEditorViewController(builder: (IMGLYSliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = IMGLYSliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        contrastEditorViewControllerOptions = IMGLYSliderEditorViewControllerOptions(builder: builderForClosure)
    }
    
    // MARK: Class replacement
    
    /**
     Use this to use a specific subclass instead of the default imglyKit classes. This works
     across all the whole framework and allows you to subclass all usages of a class.
     
     - Throws: An exception if the replacing class is not a subclass of the replaced class.
     */
    public func replaceClass(builtinClass: NSObject.Type, replacingClass: NSObject.Type, namespace: String) throws {
        
        if (!replacingClass.isSubclassOfClass(builtinClass)) {
            throw IMGLYConfigurationError.ReplacingClassNotASubclass
        }
        
        let builtinClassName = String(builtinClass)
        let replacingClassName = "\(namespace).\(String(replacingClass))"
        
        classReplacingMap[builtinClassName] = replacingClassName
        print("Using \(replacingClassName) instead of \(builtinClassName)")
    }
    
    // MARK: Private properties
    
    var classReplacingMap: [String: String] = [:]
}
