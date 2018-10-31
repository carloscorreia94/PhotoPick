//
//  PickCameraView.swift
//  PhotoPick
//
//  Created by carloscorreia on 22/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

@objc protocol PickCameraViewDelegate: class {
    func cameraShotFinished(_ image: UIImage)
    func authorized(on: Bool)
}

class PickCameraView : UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    var croppedAspectRatioConstraint: NSLayoutConstraint?
    
    
    fileprivate var flashOffImage: UIImage?
    fileprivate var flashOnImage: UIImage?
    
    static var _instance: PickCameraView!
    
    var _isReadyToSend : Bool = false
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var imageOutput: AVCaptureStillImageOutput?
    var videoInput: AVCaptureDeviceInput?
    var focusView: UIView?
    var currentImage: UIImage?
    

    weak var delegate: PickCameraViewDelegate? = nil
    
    static func instance() -> PickCameraView {
        
        return UINib(nibName: "PickCameraView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! PickCameraView
    }

    
    func initialize() {
        if session != nil {
            
            return
        }
        
        
        self.isHidden = false
        
        // AVCapture
        session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice , device.position == AVCaptureDevice.Position.back {
                
                self.device = device
                
                if !device.hasFlash {
                    
                    flashModeButton.isHidden = true
                }
            }
        }
        
        do {
            
            if let session = session, let device = device {
                
                videoInput = try AVCaptureDeviceInput(device: device)
                
                if let input = videoInput {
                    session.addInput(input)
                }
                
                imageOutput = AVCaptureStillImageOutput()
                
                if let output = imageOutput {
                    session.addOutput(output)
                }
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                
                
                
                videoLayer.frame = self.cameraView.bounds
                videoLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
                

                self.cameraView.layer.addSublayer(videoLayer)
        
                
                session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.photo))
                
                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(PickCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.cameraView.addGestureRecognizer(tapRecognizer)
            
        } catch {
            
        }
        flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PickCameraView.willEnterForegroundNotification(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    @objc func willEnterForegroundNotification(_ notification: Notification) {
        
        startCamera()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    
    func startCamera() {
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        if status == AVAuthorizationStatus.authorized {
            delegate?.authorized(on: true)

            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            delegate?.authorized(on: false)

            session?.stopRunning()
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
    }
    
    private func configureButton(_ btn: UIButton,image img: UIImage) {
        let image = img.withRenderingMode(.alwaysTemplate)

        btn.setImage(image, for: UIControl.State())
        btn.setImage(image, for: .highlighted)
        btn.setImage(image, for: .selected)
        btn.tintColor = photoPickBaseTintColor
        btn.backgroundColor = photoPickBackgroundColor
        btn.adjustsImageWhenHighlighted = false
        
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = btn.bounds.width / 2
        btn.layer.borderColor = photoPickBaseTintColor.cgColor

    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if flashOffImage == nil {
            let bundle = Bundle(for: self.classForCoder)
            
            flashOnImage = photoPickFlashOnImage != nil ? photoPickFlashOnImage : UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
            flashOffImage = photoPickFlashOffImage != nil ? photoPickFlashOffImage : UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
            
            let cameraImage = photoPickCameraImage != nil ? photoPickCameraImage : UIImage(named: "ic_camera_mode", in: bundle, compatibleWith: nil)
            let flipImage = photoPickFlipImage != nil ? photoPickFlipImage : UIImage(named: "ic_change_camera", in: bundle, compatibleWith: nil)

            configureButton(cameraButton, image: cameraImage!)
            
            configureButton(flashModeButton, image: flashOffImage!)
            
            configureButton(changeCameraButton, image: flipImage!)

        }
        
     
    }
    
    /**
     Toogle flash option to ON or OFF, and change button icon.
     
     - parameter sender: UIButton
     */
    @IBAction func changeFlashMode(_ sender: UIButton) {
        if !cameraIsAvailable() {
            startCamera()
            return
        }
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureDevice.FlashMode.off {
                    
                    device.flashMode = AVCaptureDevice.FlashMode.on
                    flashModeButton.setImage(flashOnImage, for: UIControl.State())
                    
                } else if mode == AVCaptureDevice.FlashMode.on {
                    
                    device.flashMode = AVCaptureDevice.FlashMode.off
                    flashModeButton.setImage(flashOffImage, for: UIControl.State())
                }
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            flashModeButton.setImage(flashOffImage, for: UIControl.State())
            return
        }
        
    }
    
    /**
     Toogle camera device between Front and Rear, and do a rotate animation when selected.
     
     - parameter sender: UIButton
     */
    @IBAction func changeCameraDevice(_ sender: UIButton) {
        if !cameraIsAvailable() {
            
            return
        }
        
        if currentImage != nil {
            currentImage = nil
            cameraButton.backgroundColor = photoPickBackgroundColor
        }
        
        
        session?.stopRunning()
        
        do {
            
            session?.beginConfiguration()
            
            if let session = session {
                
                for input in session.inputs {
                    
                    session.removeInput(input )
                }
                
                let position = (videoInput?.device.position == AVCaptureDevice.Position.front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                
                
                changeCameraButton.backgroundColor = videoInput?.device.position == AVCaptureDevice.Position.front ? photoPickBackgroundColor : photoPickTintColor
                
                for device in AVCaptureDevice.devices(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) {
                    
                    if let device = device as? AVCaptureDevice , device.position == position {
                        
                        videoInput = try AVCaptureDeviceInput(device: device)
                        if let input = videoInput {
                            session.addInput(input)
                        }
                        
                    }
                }
                
            }
            
            session?.commitConfiguration()
            
            
        } catch {
            
        }
        
        session?.startRunning()

        
    }
    
    /**
     Take a photo from camera and sent it.
     
     - parameter sender: UIButton
     */
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        guard let imageOutput = imageOutput else {
            
            return
        }
        
        if currentImage != nil {
            currentImage = nil
            startCamera()
            cameraButton.backgroundColor = photoPickBackgroundColor

            return
        }
        
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            
            let videoConnection = imageOutput.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
            
            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            switch (orientation) {
            case .portrait:
                videoConnection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoConnection?.videoOrientation = .portraitUpsideDown
            case .landscapeRight:
                videoConnection?.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                videoConnection?.videoOrientation = .landscapeRight
            default:
                videoConnection?.videoOrientation = .portrait
            }
            
            guard let vConnection = videoConnection else {
                return
            }
            imageOutput.captureStillImageAsynchronously(from: vConnection, completionHandler: { (buffer, error) -> Void in
                
                self.session?.stopRunning()
                
                guard let buffer = buffer else {
                    return
                }
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                if let image = UIImage(data: data!) {
                   
                    // Image size
                    var iw: CGFloat = image.size.width
                    var ih: CGFloat = image.size.height
                    
                    switch (orientation) {
                    case .landscapeLeft, .landscapeRight:
                            // Swap width and height if orientation is landscape
                            iw = image.size.height
                            ih = image.size.width
                        
                    default:
                        break
                    }
                    
                    
                    // Frame size
                    let sw = self.cameraView.frame.width
                    
                    // The center coordinate along Y axis
                    let rcy = ih * 0.5
                    
                    let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    
                   
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        var resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                        
                        //Temporary. Change orientation here, as front camera input changes it (not sure why)
                        if self.videoInput?.device.position == AVCaptureDevice.Position.front {
                            resizedImage = UIImage(cgImage: resizedImage.cgImage!, scale: 1.0, orientation: .leftMirrored)
                        }
                        self._isReadyToSend = true
                        self.stopCamera()
                        self.currentImage = resizedImage
                        self.cameraButton.backgroundColor = photoPickTintColor
                        
                    })
                }
                
            })
            
        })
        
    }

}

extension PickCameraView {
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self)
        let viewsize = self.cameraView.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {
            
            device?.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }
        
        if device?.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        //self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = photoPickBaseTintColor.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureDevice.FlashMode.off
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }
    
    func cameraIsAvailable() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        if status == AVAuthorizationStatus.authorized {
            
            delegate?.authorized(on: true)
            return true
        }
        
        delegate?.authorized(on: false)
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
