//
//  UIImage.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/22/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

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
}
