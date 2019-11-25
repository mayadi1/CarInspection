//
//  SuccessViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/25/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

class SuccessViewController: BaseViewController {
    // MARK: - UI objects
    
    @IBOutlet private var licensePlateImageView: UIImageView!
    
    // MARK: - View controller methods
    override func viewWillAppear(_ animated: Bool) {
        guard let licensePlateImage = Car.current.licensePlateImage else { return }
        licensePlateImageView.image = licensePlateImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
