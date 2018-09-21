//
//  SelfieStoreTests.swift
//  SelfiegramTests
//
//  Created by Cody on 9/21/18.
//  Copyright © 2018 HoorayArray. All rights reserved.
//

import XCTest
@testable import Selfiegram
import UIKit

class SelfieStoreTests: XCTestCase {
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    ///a helper function to create images with text being used as the image content.
    /// - returns: an image contaning a representation of the text
    /// - parameter text: the string you want rendered into the image
    func createImage(text:String) -> UIImage {
        //start a drawing canvas
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        //close the canvas after we return from this function
        defer {
            UIGraphicsEndImageContext()
        }
        
        //create a label
        let label = UILabel (frame: CGRect(x:0, y:0, width: 100, height:100))
        label.font = UIFont.systemFont(ofSize: 50)
        label.text = text
        //draw the label in the current drawing contet
        label.drawHierarchy(in: label.frame, afterScreenUpdates: true)
        
        //returns the image
        //(the ! means we either successfully get an image, or we crash)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func testCreatingSelfie() {
        //arrange
        let selfieTitle = "Creating test Selfie"
        let newSelfie = Selfie(title:selfieTitle)
        
        //act
        try? SelfieStore.shared.save(selfie: newSelfie)
        
        //assert
        let allSelfies = try! SelfieStore.shared.listSelfies()
        
        guard let theSelfie = allSelfies.first(where: {$0.id == newSelfie.id})
        
        else {
            XCTFail("Selfies list should contain the one we just created.")
            return
        }
        
        XCTAssertEqual(selfieTitle, newSelfie.title)
    }
    
    func testSavingImage() throws {
        //arrange
        let newSelfie = Selfie(title: "Slefie with image test")
        
        //act
        newSelfie.image = createImage(text: "   ")
        try SelfieStore.shared.save(selfie: newSelfie)
        
        //assert
        let loadedImage = SelfieStore.shared.getImage(id: newSelfie.id)
        
        XCTAssertNotNil(loadedImage, "The image should be loaded.")
    }
    
    func testLoadingSelfie() throws {
        //arrange
        let selfieTitle = "Test loading selfie"
        let newSelfie = Selfie(title: selfieTitle)
        try SelfieStore.shared.save(selfie:newSelfie)
        let id = newSelfie.id
        
        //act
        let loadedSelfie = SelfieStore.shared.load(id:id)
        
        //assert
        XCTAssertNotNil(loadedSelfie, "The selfie should be loaded")
        XCTAssertEqual(loadedSelfie?.id, newSelfie.id, "The loaded selfie should have the same ID")
        XCTAssertEqual(loadedSelfie?.created, newSelfie.created, "The loaded selfie should have the same creation date")
        XCTAssertEqual(loadedSelfie?.title, selfieTitle, "The loaded selfie should have the same title")
        
    }
    
    func testDeletingSelfie() throws {
        //arrange
        let newSelfie = Selfie(title: "Test deleting a Selfie")
        try SelfieStore.shared.save(selfie: newSelfie)
        let id = newSelfie.id
        
        //act
        let allSelfies = try SelfieStore.shared.listSelfies()
        try SelfieStore.shared.delete(id: id)
        let selfieList = try SelfieStore.shared.listSelfies()
        let loadedSelfie = SelfieStore.shared.load(id: id)
        
        //assert
        XCTAssertEqual(allSelfies.count - 1, selfieList.count, "There should be one less after deletion")
        XCTAssertNil(loadedSelfie, "deleted selfie should be nil")
    }
    
}





















