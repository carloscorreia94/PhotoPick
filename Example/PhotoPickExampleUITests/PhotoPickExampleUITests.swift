//
//  PhotoPickExampleUITests.swift
//  PhotoPickExampleUITests
//
//  Created by Carlos Correia on 07/08/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import XCTest

class PhotoPickExampleUITests: XCTestCase {
    
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launch()
    
        continueAfterFailure = false
        
        //XCUIDevice.shared().orientation = .faceUp
        //XCUIDevice.shared().orientation = .faceUp
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPickModeChange() {
        
        //Given
        app.otherElements.containing(.button, identifier:"OPEN").element.tap()
        app.buttons["OPEN"].tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        
        let cameraButton = element.children(matching: .button).element(boundBy: 1)
        let libraryButton = element.children(matching: .button).element(boundBy: 0)

        
        
        let libraryView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .scrollView).element
        
        let cameraView =  app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        
        //when
        cameraButton.tap()
        
        //then
        
        if cameraButton.isSelected {
            XCTAssertTrue(cameraView.exists)
            XCTAssertFalse(libraryView.exists)
            
            libraryButton.tap()
            
            XCTAssertTrue(libraryView.exists)
            XCTAssertFalse(cameraView.exists)
        }
    }
    
}
