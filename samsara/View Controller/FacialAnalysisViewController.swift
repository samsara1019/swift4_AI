//
//  FacialAnalysisViewController.swift
//  samsara
//
//  Created by 이윤혜 on 2018. 4. 14..
//  Copyright © 2018년 이윤혜. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class FacialAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var selectedImage: UIImage? {
        didSet{
            self.blurredImageView.image = selectedImage
            self.selectedImageView.image = selectedImage
        }
    }
    
    var selectedCiImage: CIImage? {
        get{
            if let selectedImage = self.selectedImage{
                return CIImage(image: selectedImage)
            } else {
                return nil
            }
        }
    }
    
    var faceImageViews = [UIImageView]()
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var facesScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let importFromAlbum = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "카메라로 찍기", style: .default) {_ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(importFromAlbum)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let uiImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.selectedImage = uiImage
            self.removeRectangles()
            self.removeFaceImageViews()
            
            DispatchQueue.global(qos: .userInitiated).async{
                self.detectFaces()
            }
        }
        
    }
    
    func detectFaces(){
        if let ciImage = self.selectedCiImage{
            let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces)
            let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do{
                try requestHandler.perform([detectFaceRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func handleFaces(request: VNRequest, error: Error?){
        if let faces = request.results as? [VNFaceObservation]{
            DispatchQueue.main.async {
                self.displayUI(for: faces)
            }
        }
    }
    
    func displayUI(for faces: [VNFaceObservation]){
        if let faceImage = self.selectedImage{
            let imageRect = AVMakeRect(aspectRatio: faceImage.size, insideRect: self.selectedImageView.bounds)
            
            for (index, face) in faces.enumerated() {
                let w = face.boundingBox.size.width * imageRect.width
                let h = face.boundingBox.size.height * imageRect.height
                let x = face.boundingBox.origin.x * imageRect.width
                let y = imageRect.maxY - (face.boundingBox.origin.y * imageRect.height) - h
                
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: x, y: y, width: w, height: h)
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 1
                self.selectedImageView.layer.addSublayer(layer)
                
                
                let w2 = face.boundingBox.size.width * faceImage.size.width
                let h2 = face.boundingBox.size.height * faceImage.size.height
                let x2 = face.boundingBox.origin.x * faceImage.size.width
                let y2 = (1 - face.boundingBox.origin.y) * faceImage.size.height - h2
                
                let cropRect = CGRect(x: x2 * faceImage.scale, y: y2 * faceImage.scale, width: w2 * faceImage.scale, height: h2 * faceImage.scale)
                
                if let faceCgImage = faceImage.cgImage?.cropping(to: cropRect){
                    let faceUiImage = UIImage(cgImage: faceCgImage, scale: faceImage.scale, orientation: .up)
                    let faceImageView = UIImageView(frame: CGRect(x: 90*index, y: 0, width: 80, height: 80))
                    faceImageView.image = faceUiImage
                    
                    self.faceImageViews.append(faceImageView)
                    self.facesScrollView.addSubview(faceImageView)
                }
            }
            
            self.facesScrollView.contentSize = CGSize(width: 90*faces.count-10, height: 80)
        }
    }
    
    func removeRectangles(){
        if let sublayers = self.selectedImageView.layer.sublayers{
            for layer in sublayers{
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func removeFaceImageViews(){
        for faceImageView in self.faceImageViews{
            faceImageView.removeFromSuperview()
        }
        
        self.faceImageViews.removeAll()
    }
}
