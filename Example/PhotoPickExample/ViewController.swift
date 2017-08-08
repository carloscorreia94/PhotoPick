//
//  ViewController.swift
//  PhotoPick
//
//  Created by CarlosCorreia on 2017/07/21.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, PhotoPickDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var showButton: UIButton!
    
    let photoPick = PhotoPickViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoPick.delegate = self
        photoPick.defaultMode     = .library

        showButton.layer.cornerRadius = 2.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showButtonPressed(_ sender: AnyObject) {
        
        // Show PhotoPick
        
       
        self.present(photoPick, animated: true, completion: nil)
    }
    
    // MARK: PhotoPickDelegate Protocol
    func pickImageSelected(_ image: UIImage, source: PickMode) {
        
        switch source {
            
        case .camera:
            
            print("Image captured from Camera")
        
        case .library:
            
            print("Image selected from Camera Roll")
        
        default:
        
            print("Image selected")
        }
        
        imageView.image = image
    }
    


   

    

    func pickCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested",
                                      message: "Saving image needs to access your photo album",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                
                UIApplication.shared.openURL(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickClosed() {
        
        print("Called when the PhotoPickViewController disappeared")
    }
    
    func pickWillClose() {
        
        print("Called when the close button is pressed")
    }

}

extension ViewController {
    func addPhotoToCameraRoll(_ completion: (()->())? = nil) {
        
        let libraryImage = UIImage(named: "ic_library_mode", in: Bundle(for: self.classForCoder), compatibleWith: nil)!

        
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: libraryImage)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            
            let optionsSort = PHFetchOptions()
            optionsSort.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: PHFetchOptions())
            
            let first = userAlbums.firstObject ?? PHAssetCollection()
            
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: first)
            
            let arrayPlaceHolder : NSArray = [assetPlaceholder!]
            albumChangeRequest?.addAssets(arrayPlaceHolder)
            
            
        }, completionHandler: { success, error in
            if let comp = completion {
                comp()
            }
        })
    }
    
}



