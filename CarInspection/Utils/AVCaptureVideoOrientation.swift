//
//  AVCaptureVideoOrientation.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/13/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit
import AVFoundation

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}
