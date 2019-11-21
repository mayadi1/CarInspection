//
//  UIView+LayerHelpers.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/21/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

protocol BoolPropertyStoring {
    associatedtype BoolType
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: BoolType) -> BoolType
}

protocol CGFloatPropertyStoring {
    associatedtype FloatType
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: FloatType) -> FloatType
}

protocol ColorPropertyStoring {
    associatedtype ColorType
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: ColorType) -> ColorType
}

extension BoolPropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: BoolType) -> BoolType {
        guard let value = objc_getAssociatedObject(self, key) as? BoolType else {
            return defaultValue
        }
        return value
    }
}

extension CGFloatPropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: FloatType) -> FloatType {
        guard let value = objc_getAssociatedObject(self, key) as? FloatType else {
            return defaultValue
        }
        return value
    }
}

extension ColorPropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: ColorType) -> ColorType {
        guard let value = objc_getAssociatedObject(self, key) as? ColorType else {
            return defaultValue
        }
        return value
    }
}

@IBDesignable
extension UIView: BoolPropertyStoring, CGFloatPropertyStoring, ColorPropertyStoring {
    typealias BoolType = Bool
    typealias FloatType = CGFloat
    typealias ColorType = UIColor

    private struct CustomProperties {
        static var topLeft = true
        static var bottomLeft = true
        static var topRight = true
        static var bottomRight = true
        static var defaultShadowStyle = true
        static var cornerRadius: CGFloat = 0
        static var borderColor: UIColor = .clear
        static var borderWidth: CGFloat = 0
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            return ((layer.shadowColor != nil) ? UIColor(cgColor: layer.shadowColor!) : nil)
        }
        set {
            layer.shadowColor = (newValue != nil) ? newValue!.cgColor : nil
        }
    }
    
    @IBInspectable
    var shadowOffsetWidth: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset.width = newValue
        }
    }
    
    @IBInspectable
    var shadowOffsetHeight: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }
    
    @IBInspectable
    var defaultShadowStyle: Bool {
        get {
            return getAssociatedObject(&CustomProperties.defaultShadowStyle, defaultValue: CustomProperties.defaultShadowStyle)
        }
        set {
            if newValue {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOffset = CGSize(width: 0, height: -1)
                layer.shadowRadius = 3
                layer.shadowOpacity = 0.2
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
            }
            return objc_setAssociatedObject(self, &CustomProperties.defaultShadowStyle, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var topLeft: Bool {
        get {
            return getAssociatedObject(&CustomProperties.topLeft, defaultValue: CustomProperties.topLeft)
        }
        set {
            if newValue {
                layer.maskedCorners.update(with: .layerMinXMinYCorner)
            } else {
                layer.maskedCorners.subtract(.layerMinXMinYCorner)
            }
            return objc_setAssociatedObject(self, &CustomProperties.topLeft, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var bottomLeft: Bool {
        get {
            return getAssociatedObject(&CustomProperties.bottomLeft, defaultValue: CustomProperties.bottomLeft)
        }
        set {
            if newValue {
                layer.maskedCorners.update(with: .layerMinXMaxYCorner)
            } else {
                layer.maskedCorners.subtract(.layerMinXMaxYCorner)
            }
            return objc_setAssociatedObject(self, &CustomProperties.bottomLeft, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var topRight: Bool {
        get {
            return getAssociatedObject(&CustomProperties.topRight, defaultValue: CustomProperties.topRight)
        }
        set {
            if newValue {
                layer.maskedCorners.update(with: .layerMaxXMinYCorner)
            } else {
                layer.maskedCorners.subtract(.layerMaxXMinYCorner)
            }
            return objc_setAssociatedObject(self, &CustomProperties.topRight, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var bottomRight: Bool {
        get {
            return getAssociatedObject(&CustomProperties.bottomRight, defaultValue: CustomProperties.bottomRight)
        }
        set {
            if newValue {
                layer.maskedCorners.update(with: .layerMaxXMaxYCorner)
            } else {
                layer.maskedCorners.subtract(.layerMaxXMaxYCorner)
            }
            return objc_setAssociatedObject(self, &CustomProperties.bottomRight, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return getAssociatedObject(&CustomProperties.cornerRadius, defaultValue: CustomProperties.cornerRadius)
        }
        set {
            layer.cornerRadius = newValue
            return objc_setAssociatedObject(self, &CustomProperties.cornerRadius, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return getAssociatedObject(&CustomProperties.borderWidth, defaultValue: layer.borderWidth)
        }
        set {
            layer.borderWidth = newValue
            return objc_setAssociatedObject(self, &CustomProperties.borderWidth, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            return getAssociatedObject(&CustomProperties.borderColor, defaultValue: UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor))
        }
        set {
            layer.borderColor = newValue.cgColor
            return objc_setAssociatedObject(self, &CustomProperties.borderColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
