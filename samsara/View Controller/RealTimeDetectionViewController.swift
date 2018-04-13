//
//  RealTimeDetectionViewController.swift
//  samsara
//
//  Created by 이윤혜 on 2017. 11. 29..
//  Copyright © 2017년 이윤혜. All rights reserved.
//

import UIKit
import Vision

class RealTimeDetectionViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    var videoCapture: VideoCapture!
    
    let visionRequestHandler = VNSequenceRequestHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryLabel.text = " "
        self.confidenceLabel.text = " "

        let spec = VideoSpec(fps: 3, size: CGSize(width: 1280, height: 720))
        self.videoCapture = VideoCapture(cameraType: .back, preferredSpec: spec, previewContainer: self.cameraView.layer)
        self.videoCapture.imageBufferHandler = { (imageBuffer, timestemp, outputBuffer) in
            self.detectObject(image: imageBuffer)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let videoCapture = self.videoCapture{
            videoCapture.startCapture()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoCapture = self.videoCapture {
            videoCapture.stopCapture()
        }
    }
    
    func detectObject(image: CVImageBuffer){
        do{
            let vnCoreMLModel = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: vnCoreMLModel, completionHandler: self.handleObjectDetection)
            request.imageCropAndScaleOption = .centerCrop
            try self.visionRequestHandler.perform([request], on: image)
        } catch {
            print(error)
        }
    }
    
    func handleObjectDetection(request: VNRequest, error: Error?){
        if let result = request.results?.first as? VNClassificationObservation{
            self.categoryLabel.text = result.identifier
            self.confidenceLabel.text = "\(String(format: "%.1f", result.confidence * 100))%"
        }
    }
}
