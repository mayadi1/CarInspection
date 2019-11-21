//
//  BaseViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/12/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

/// BaseViewController.
class BaseViewController: UIViewController {
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
    }
    
    // MARK: Private func
    
    private func setupNavBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
    }
}

