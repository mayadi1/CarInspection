//
//  Car.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/21/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

class Car {
    
    static var current = Car()
    
    var make: String?
    var year: String?
    var vin: String?
    var model: String?
    var transmissionStyle: String?
    var bodyClass: String?
    var license: String?
    var barcodeImage: UIImage?
}
 
