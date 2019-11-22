//
//  HomeViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/22/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    // MARK: - UI objects
    
    
    // MARK: - View controller methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

 

}
