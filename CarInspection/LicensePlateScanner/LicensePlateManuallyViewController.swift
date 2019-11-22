//
//  LicensePlateManuallyViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/22/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

class LicensePlateManuallyViewController: BaseViewController {
    // MARK: - UI objects
   
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var licenseLabel: UITextField!
    
    // MARK: - View controller methods

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Step 2 of 4"
     
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let text = licenseLabel.text else { return false }
        if text.length <= 1 { return false }
        
        Car.current.license = text

        return true
    }
}
