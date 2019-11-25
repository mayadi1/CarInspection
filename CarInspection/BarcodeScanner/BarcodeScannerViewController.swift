//
//  BarcodeScannerViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/12/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import UIKit
import AVFoundation

/// Handles barcode scan..
class BarcodeScannerViewController: BaseViewController {
    // MARK: - UI objects
    
    @IBOutlet private var videoView:UIView!
    @IBOutlet private var vinTextLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    
    private var allowedTypes: [AVMetadataObject.ObjectType] = [.code39, .upce]

    // MARK: - View controller methods
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Step 1 of 4"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
        
        // Retrieve the default capturing device for using the camera
        self.captureDevice = AVCaptureDevice.default(for: .video)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject!
        do {
            if let captureDevice = self.captureDevice {
                input = try AVCaptureDeviceInput(device: captureDevice)
                
                if (error != nil) {
                    // If any error occurs, simply log the description of it and don't continue any more.
                    print("\(String(describing: error?.localizedDescription))")
                    return
                }
                
                // Initialize the captureSession object and set the input device on the capture session.
                captureSession = AVCaptureSession()
                captureSession?.addInput(input as! AVCaptureInput)
                
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)

                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.allowedTypes
                
                // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
                
                if let captureSession = captureSession {
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
                    videoPreviewLayer?.frame = videoView.layer.bounds
                    videoView.layer.addSublayer(videoPreviewLayer!)
                    
                    // Start video capture.
                    captureSession.startRunning()
                }
            }
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
 
            if let code = metadataObj.stringValue {
                captureSession?.stopRunning()
            
                let attributedString = NSMutableAttributedString(string: "Vin: \(code)", attributes: [
                  .foregroundColor: UIColor.init(named: "gray") ?? UIColor.systemGray
                ])
                
                attributedString.addAttributes([
                  .foregroundColor: UIColor.systemBlue,
                  .font: UIFont.systemFont(ofSize: 19.0, weight: .bold),
                ], range: NSRange(location: 4, length: code.length))
                
                vinTextLabel.attributedText = attributedString
                nextButton.backgroundColor = .systemBlue
                Car.current.vin = code
                nextButton.isEnabled = true
             }
        }
    }
 
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}
