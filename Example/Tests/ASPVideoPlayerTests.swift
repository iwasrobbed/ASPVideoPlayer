//
//  ASPVideoPlayerTests.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 17/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerTests: ASPTestCase {
        
	let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testSetGravity_ShouldSetGravity() {
		let sut = ASPVideoPlayer()
		
		sut.videoPlayerView?.gravity = .resize
		
		XCTAssertEqual(sut.videoPlayerView?.gravity, .resize, "Player gravity not set correctly.")
	}
	
	func testSetShouldLoop_ShouldSetShouldLoop() {
		let sut = ASPVideoPlayer()
		
		sut.videoPlayerView?.shouldLoop = true
		
		XCTAssertEqual(sut.videoPlayerView?.shouldLoop, true, "Player shouldLoop not set correctly.")
	}
	
    func testSetVideoURL_ShouldSetVideoURL() {
        let sut = ASPVideoPlayer()
        
        sut.videoURL = videoURL
        
        XCTAssertEqual(sut.videoURLs.first, videoURL, "Player URLs not set correctly.")
        XCTAssertEqual(sut.videoURLs.count, 1, "Player URLs not set correctly.")
    }
    
	func testSetVideoURLs_ShouldSetVideoURLs() {
		let sut = ASPVideoPlayer()
		
		sut.videoURLs = [videoURL]
		
		XCTAssertEqual(sut.videoURLs.first, videoURL, "Player URLs not set correctly.")
		XCTAssertEqual(sut.videoURLs.count, 1, "Player URLs not set correctly.")
	}
	
	func testSetTintColor_ShouldSetTintColorForVideoControls() {
		let sut = ASPVideoPlayer()
		
		sut.tintColor = UIColor.blue
		
		XCTAssertEqual(sut.tintColor, UIColor.blue, "Player tint color not set correctly.")
		XCTAssertEqual(sut.tintColor, sut.videoPlayerControls?.tintColor, "Player tint color not set correctly.")
	}
	
	func testControlsVisibleAndPlayerStarting_ShouldHideControls() {
		let sut = ASPVideoPlayer()
		sut.videoURL = videoURL
		sut.videoPlayerControls?.play()

		XCTAssertEqual(sut.videoPlayerControls?.alpha, 0.0, "Player controls are visible.")
	}
	
	func testControlsHiddenAndPlayerRunningToggleControls_ShouldShowControls() {
		let sut = ASPVideoPlayer()
		sut.videoURL = videoURL
		sut.videoPlayerControls?.play()
		sut.hideControls()
		
		sut.toggleControls()

		XCTAssertEqual(sut.videoPlayerControls?.alpha, 1.0, "Player controls are not visible.")
	}
}
