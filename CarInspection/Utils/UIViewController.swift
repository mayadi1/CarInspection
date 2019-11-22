//
//  UIViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/22/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideNavigationBar(){
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }

    func showNavigationBar() {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
