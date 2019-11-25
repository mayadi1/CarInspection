//
//  UIImage.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/22/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    convenience init?(barcode: String) {
        let data = barcode.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        guard let ciImage = filter.outputImage else {
            return nil
        }
        self.init(ciImage: ciImage)
    }
    
    convenience init?(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation = .upMirrored) {
           guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
           CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
           defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
           let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
           let width = CVPixelBufferGetWidth(pixelBuffer)
           let height = CVPixelBufferGetHeight(pixelBuffer)
           let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
           let colorSpace = CGColorSpaceCreateDeviceRGB()
           let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
           guard let context = CGContext(data: baseAddress, width: width, height: height,
                                         bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                         space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }

           guard let cgImage = context.makeImage() else { return nil }
           self.init(cgImage: cgImage, scale: 1, orientation: orientation)
       }
}

import UIKit

extension UIApplication {
    private class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    class var topViewController: UIViewController? { return topViewController() }
}
