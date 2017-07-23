//
//  ViewController.swift
//  PhotoPick
//
//  Created by CarlosCorreia on 2017/07/21.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PhotoPickDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var showButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let photoPick = PhotoPickViewController()
        
        photoPick.delegate = self
        photoPick.defaultMode     = .library

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

