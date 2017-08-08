//
//  PhotoPickExampleTests.swift
//  PhotoPickExampleTests
//
//  Created by Carlos Correia on 08/08/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import XCTest

@testable import PhotoPickExample


class PhotoPickExampleTests: XCTestCase {
    
    var viewController : ViewController!
    var photoPickViewController : PhotoPickViewController!
    var bundle : Bundle!

    override func setUp() {
        super.setUp()
        
        bundle = Bundle(for: self.classForCoder)

        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController
        //viewController.present(viewController.photoPick, animated: true, completion: nil)

        photoPickViewController = PhotoPickViewController()
        photoPickViewController.viewDidLoad()
        photoPickViewController.viewDidAppear(true)

    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testHasExtraAsset() {
        
        let promise = expectation(description: "ok")
        
        let initialAssetCount = photoPickViewController.albumView.assets?.count ?? 0

        
        viewController.addPhotoToCameraRoll({
            self.photoPickViewController.albumView.updateLibrary()
            
            if self.photoPickViewController.albumView.assets?.count ?? 0 == initialAssetCount + 1 {
                promise.fulfill()
            } else {
                XCTFail()
            }
            
        })

        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
   /* func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    } */

}
