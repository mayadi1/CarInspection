
//
//  VinDecoderViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/21/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit
 

class VinDecoderViewController: BaseViewController {
   // MARK: - UI objects
    
    @IBOutlet private var makeLabel: UILabel!
    @IBOutlet private var modelLabel: UILabel!
    @IBOutlet private var yearLabel: UILabel!
    @IBOutlet private var topVinLabel: UILabel!
    @IBOutlet private var vinLabel: UILabel!
    @IBOutlet private var classLabel: UILabel!
    @IBOutlet private var transmissionLabel: UILabel!
    @IBOutlet private var barcodeImage: UIImageView!
    
    // MARK: - View controller methods

    override func viewWillAppear(_ animated: Bool) {
        guard let vin = Car.current.vin else { return }
         barcodeImage.image = UIImage(barcode: vin)
        
         VehicleAPI.shared.decodeVin(vin: vin) { (err) in
            DispatchQueue.main.async {
                self.displayCarInfo()
            }
        }
    }
        
    // MARK: - Private methods
    
    private func displayCarInfo() {
        makeLabel.text = Car.current.make
        modelLabel.text = Car.current.model
        yearLabel.text = Car.current.year
        vinLabel.text = Car.current.vin
        topVinLabel.text = Car.current.vin
        classLabel.text = Car.current.bodyClass
        transmissionLabel.text = Car.current.transmissionStyle
    }
}
