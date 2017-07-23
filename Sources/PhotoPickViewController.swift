//
//  PhotoPickViewController.swift
//  PhotoPick
//
//  Created by CarlosCorreia on 2017/07/21.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit
import Photos


public protocol PhotoPickDelegate: class {
    
    func pickImageSelected(_ image: UIImage, source: PickMode)

    func pickCameraRollUnauthorized()
    
    // optional
    func pickClosed()
    func pickWillClose()
}

public extension PhotoPickDelegate {
    
    func pickClosed() {}
    func pickWillClose() {}
}

public var photoPickBaseTintColor   = UIColor.white
public var photoPickTintColor       = UIColor().HexToColor(hexString: "098b78")
public var photoPickBackgroundColor = UIColor.darkGray

public var photoPickAlbumImage: UIImage?
public var photoPickCameraImage: UIImage?
public var photoPickCheckImage: UIImage?
public var photoPickCloseImage: UIImage?
public var photoPickFlashOnImage: UIImage?
public var photoPickFlashOffImage: UIImage?
public var photoPickFlipImage: UIImage?
public var photoPickShotImage: UIImage?





public var photoPickCameraRollTitle = "Galeria"
public var photoPickCameraTitle     = "Camera"
public var photoPickTitleFont       = UIFont(name: "TitilliumWeb-SemiBold", size: 15)


@objc public enum PickMode: Int {
    
    case camera
    case library
    case none
}


@objc public class PhotoPickViewController: UIViewController {

 

    fileprivate var mode: PickMode = .none
    public var defaultMode: PickMode = .library
    fileprivate var willFilter = true

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    
    lazy var albumView  = PickLibraryView.instance()
    lazy var cameraView = PickCameraView.instance()

    fileprivate var hasGalleryPermission = PHPhotoLibrary.authorizationStatus() == .authorized
    
    public weak var delegate: PhotoPickDelegate? = nil
    
    override public func loadView() {
        
        if let view = UINib(nibName: "PhotoPickViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = photoPickBackgroundColor
        
        cameraView.delegate = self
        albumView.delegate  = self

        menuView.backgroundColor = photoPickBackgroundColor
        menuView.bottomBorder(UIColor.black, width: 1.0)

        
        let bundle = Bundle(for: self.classForCoder)
        
        var albumImage = photoPickAlbumImage != nil ? photoPickAlbumImage : UIImage(named: "ic_library_mode", in: bundle, compatibleWith: nil)
        var cameraImage = photoPickCameraImage != nil ? photoPickCameraImage : UIImage(named: "ic_camera_mode", in: bundle, compatibleWith: nil)


        
        var checkImage = photoPickCheckImage != nil ? photoPickCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        var closeImage = photoPickCloseImage != nil ? photoPickCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        
        albumImage  = albumImage?.withRenderingMode(.alwaysTemplate)
        cameraImage = cameraImage?.withRenderingMode(.alwaysTemplate)
        closeImage  = closeImage?.withRenderingMode(.alwaysTemplate)
        checkImage  = checkImage?.withRenderingMode(.alwaysTemplate)

        libraryButton.setImage(albumImage, for: UIControlState())
        libraryButton.setImage(albumImage, for: .highlighted)
        libraryButton.setImage(albumImage, for: .selected)
        libraryButton.tintColor = photoPickTintColor
        libraryButton.adjustsImageWhenHighlighted = false

        cameraButton.setImage(cameraImage, for: UIControlState())
        cameraButton.setImage(cameraImage, for: .highlighted)
        cameraButton.setImage(cameraImage, for: .selected)
        cameraButton.tintColor = photoPickTintColor
        cameraButton.adjustsImageWhenHighlighted = false
            
        closeButton.setImage(closeImage, for: UIControlState())
        closeButton.setImage(closeImage, for: .highlighted)
        closeButton.setImage(closeImage, for: .selected)
        closeButton.tintColor = photoPickBaseTintColor
            
        doneButton.setImage(checkImage, for: UIControlState())
        doneButton.setImage(checkImage, for: .highlighted)
        doneButton.setImage(checkImage, for: .selected)
        doneButton.tintColor = photoPickBaseTintColor
            

        
        cameraButton.clipsToBounds  = true
        libraryButton.clipsToBounds = true
        
        photoLibraryViewerContainer.addSubview(albumView)
        cameraShotContainer.addSubview(cameraView)
        
        titleLabel.textColor = photoPickBaseTintColor
        titleLabel.font      = photoPickTitleFont
        

        albumView.isHidden = true
        cameraView.isHidden = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        albumView.frame  = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
        albumView.layoutIfNeeded()
        cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()

        albumView.initialize()
        cameraView.initialize()
        
       
        
        changeMode(defaultMode)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.stopAll()
    }

    override public var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        self.delegate?.pickWillClose()
        
        self.dismiss(animated: true) {
        
            self.delegate?.pickClosed()
        }
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        changeMode(.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    
        changeMode(.camera)
    }
    
 
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        photoPickDidFinishInSingleMode()
    }
    
    private func photoPickDidFinishInSingleMode() {
        
        if self.mode == .camera {
            if let image = cameraView.currentImage {
                delegate?.pickImageSelected(image, source: .camera)
                self.dismiss(animated: true)
            } else {
                let ac = UIAlertController(title: "PhotoPick", message: "No camera photo shot.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        
            return
        }
        
        
        if let _ = albumView.imageView.image, let image = albumView.cropImage() {
            self.delegate?.pickImageSelected(image, source: .library)

            self.dismiss(animated: true, completion: nil)
            
        }
            
        
    }
    
}

extension PhotoPickViewController: PickLibraryViewDelegate, PickCameraViewDelegate {
    
    
    // MARK: PickCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        
        delegate?.pickImageSelected(image, source: mode)
        
        self.dismiss(animated: true)
    }
    
    public func albumViewCameraRollAuthorized() {
        
        // in the case that we're just coming back from granting photo gallery permissions
        // ensure the done button is visible if it should be
        hasGalleryPermission = true
        self.updateDoneButtonVisibility()
    }
    
    // MARK: PickLibraryViewDelegate
    public func albumViewCameraRollUnauthorized() {
        
        delegate?.pickCameraRollUnauthorized()
    }
    
    public func getViewController() -> UIViewController {
        return self
    }
   
    
}

private extension PhotoPickViewController {
    
    func stopAll() {
        
        self.cameraView.stopCamera()
    }
    
    func changeMode(_ mode: PickMode) {

        if self.mode == mode { return }
        
        //operate this switch before changing mode to stop cameras
        switch self.mode {
            
        case .camera:
            
            self.cameraView.stopCamera()
        
            
        default:
        
            break
        }
        
        self.mode = mode
        
        dishighlightButtons()
        updateDoneButtonVisibility()
        
        switch mode {
            
        case .library:
            
            titleLabel.text = NSLocalizedString(photoPickCameraRollTitle, comment: photoPickCameraRollTitle)
            highlightButton(libraryButton)
            self.view.bringSubview(toFront: photoLibraryViewerContainer)
            albumView.isHidden = false
        
        case .camera:

            titleLabel.text = NSLocalizedString(photoPickCameraTitle, comment: photoPickCameraTitle)
            highlightButton(cameraButton)
            self.view.bringSubview(toFront: cameraShotContainer)
            cameraView.isHidden = false
            cameraView.startCamera()
            
       
            
        default:
            
            break
        }
        
        doneButton.isHidden = !hasGalleryPermission
        self.view.bringSubview(toFront: menuView)
    }
    
    func updateDoneButtonVisibility() {

        // don't show the done button without gallery permission
        if !hasGalleryPermission {
            
            self.doneButton.isHidden = true
            return
        }

        switch self.mode {
            
        case .library:
            
            self.doneButton.isHidden = false
            
        default:
            
            self.doneButton.isHidden = true
        }
    }
    
    func dishighlightButtons() {
        
        cameraButton.tintColor  = photoPickBaseTintColor
        libraryButton.tintColor = photoPickBaseTintColor

        if cameraButton.layer.sublayers?.count > 1,
            let sublayers = cameraButton.layer.sublayers {
            
            for layer in sublayers {
                
                if let borderColor = layer.borderColor,
                    UIColor(cgColor: borderColor) == photoPickTintColor {
                    
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        if libraryButton.layer.sublayers?.count > 1,
            let sublayers = libraryButton.layer.sublayers {
            
            for layer in sublayers {
                
                if let borderColor = layer.borderColor,
                    UIColor(cgColor: borderColor) == photoPickTintColor {
                    
                    layer.removeFromSuperlayer()
                }
            }
        }
        
    }
    
    func highlightButton(_ button: UIButton) {
        
        button.tintColor = photoPickTintColor
        button.bottomBorder(photoPickTintColor, width: 3)
    }
}
