//
//  ViewControllerTests.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 16/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer_Example

class ViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testViewControllerViewCreated_ShouldLoadViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "ASPPlayerViewViewController") as? ViewController
        let view = sut?.view
        
        XCTAssertNotNil(view, "View is not nil.")
        XCTAssertNotNil(sut?.videoPlayer, "Video player is not nil.")
    }
}
