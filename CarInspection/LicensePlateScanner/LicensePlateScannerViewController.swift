//
//  LicensePlateScannerViewController.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/11/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision

/// Handles camera, preview, cutout UI and vision.
class LicensePlateScannerViewController: BaseViewController {
    // MARK: - UI objects
    
    @IBOutlet private var previewView: PreviewView!
    @IBOutlet private var cutoutView: UIView!
    @IBOutlet private var licensePlateTextLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    
    private let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "ayadios.com.CarInspectionCaptureSessionQueue")
    
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "ayadios.com.CarInspection.VideoDataOutputQueue")
    
    private var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    private var textOrientation = CGImagePropertyOrientation.right
    
    private var bufferAspectRatio: Double!
    private var uiRotationTransform = CGAffineTransform.identity
    private var bottomToTopTransform = CGAffineTransform.identity
    private var roiToGlobalTransform = CGAffineTransform.identity
    
    private var visionToAVFTransform = CGAffineTransform.identity
    private var maskLayer = CAShapeLayer()
    private var request: VNRecognizeTextRequest!
    private var captureDevice: AVCaptureDevice?
    private let numberTracker = StringTracker()
    private var boxLayer = [CAShapeLayer]()
    
    // MARK: - View controller methods

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Step 2 of 4"
        
        // Set up preview view.
        previewView.session = captureSession
        
        // Set up cutout view.
        cutoutView.backgroundColor = UIColor.init(named: "gray")
    
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        cutoutView.layer.mask = maskLayer
        
        // Using dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()
            DispatchQueue.main.async {
                self.calculateRegionOfInterest()
            }
        }
    }
    
    override func viewDidLoad() {
        // Set up vision request so it exists when the first buffer is received.
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        super.viewDidLoad()
        
        nextButton.isEnabled = false
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCutout()
    }
    
    // MARK: - Setup
    
    private func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.8
        let desiredWidthRatio = 1.0
        let maxPortraitWidth = 1.0
        
        // Figure out size of ROI.
        let size: CGSize
        size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)

        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size

        setupOrientationAndTransform()
        
        DispatchQueue.main.async {
            self.updateCutout()
        }
    }
    
   private func updateCutout() {
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))
        
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer.path = path.cgPath
    }
    
   private func setupOrientationAndTransform() {
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        
        uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
    
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { return }
        self.captureDevice = captureDevice
        
        // Use the smallest buffer size necessary to keep down battery usage.
        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        // Configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        }
        
        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
        
        captureSession.startRunning()
    }
    
    // MARK: - Text recognition
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        var numbers = [String]()
        var redBoxes = [CGRect]()
        var greenBoxes = [CGRect]()
        
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        
        let maximumCandidates = 1
        
        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            // Draw red boxes around any detected text, and green boxes around any detected license plate.
            var numberIsSubstring = true
            
            let (range, number) = (candidate.string.range(of: candidate.string) , candidate.string)
            if let box = try? candidate.boundingBox(for: range!)?.boundingBox {
                    numbers.append(number)
                    greenBoxes.append(box)
                numberIsSubstring = !(range!.lowerBound == candidate.string.startIndex && range!.upperBound == candidate.string.endIndex)
                }
             
            if numberIsSubstring {
                redBoxes.append(visionResult.boundingBox)
            }
        }
        
        // Log any found numbers.
        numberTracker.logFrame(strings: numbers)
        show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])
        
        // Check if we have any temporally stable numbers.
        if let sureNumber = numberTracker.getStableString() {
            showString(string: sureNumber)
            numberTracker.reset(string: sureNumber)
        }
    }
    
    // MARK: - Bounding box drawing

    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    // Remove all drawn boxes. Must be called on main queue.
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
    
    // Draws groups of colored boxes.
    func show(boxGroups: [ColoredBoxGroup]) {
        DispatchQueue.main.async {
            let layer = self.previewView.videoPreviewLayer
            self.removeBoxes()
            for boxGroup in boxGroups {
                let color = boxGroup.color
                for box in boxGroup.boxes {
                    let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
                    self.draw(rect: rect, color: color)
                }
            }
        }
    }
    
    // MARK: - UI drawing and interaction
    
    private func showString(string: String) {
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                
                let attributedString = NSMutableAttributedString(string: "Vin: \(string)", attributes: [
                    .foregroundColor: UIColor.init(named: "gray") ?? UIColor.systemGray
                ])
                
                attributedString.addAttributes([
                  .foregroundColor: UIColor.systemBlue,
                  .font: UIFont.systemFont(ofSize: 19.0, weight: .bold),
                ], range: NSRange(location: 4, length: string.length))
                
                self.licensePlateTextLabel.attributedText = attributedString
                self.nextButton.backgroundColor = .systemBlue
                self.nextButton.isEnabled = true
            }
        }
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
        }
        return true
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension LicensePlateScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.regionOfInterest = regionOfInterest
    
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}
