//
//  BarcodeManuallyViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/21/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

class BarcodeManuallyViewController: BaseViewController {
    // MARK: - UI objects
    @IBOutlet private var nextButton: UIButton!
    
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
    }
}

extension BarcodeManuallyViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let vinNumber = textField.text else { return true }
        
        if vinNumber.length != 17 {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.init(named: "gray")
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .systemBlue
            Car.current.vin = vinNumber
        }
        
        return true
    }
}
