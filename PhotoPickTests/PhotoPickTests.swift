//
//  PhotoPickTests.swift
//  PhotoPickTests
//
//  Created by Carlos Correia on 02/08/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import XCTest

@testable import PhotoPick
//@testable import Photos



class PhotoPickTests: XCTestCase {
    
    var photoPickViewController : PhotoPickViewController!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: self.classForCoder)
        
        let libraryImage = UIImage(named: "ic_library_mode", in: bundle, compatibleWith: nil)!
        
        UIImageWriteToSavedPhotosAlbum(libraryImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    
        photoPickViewController = PhotoPickViewController(nibName: "PhotoPickViewController", bundle: bundle)
        photoPickViewController.viewDidLoad()
        photoPickViewController.viewDidAppear(true)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHasAsset() {
       XCTAssertTrue(photoPickViewController.albumView.assets?.count ?? 0 == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    
        if let error = error {
            print("error saving photo")
           print(error.localizedDescription)
        } else {
            print("saved photo")
        }
    }
}
