//
//  ASPVideoPlayerViewControlerTests.swift
//  ASPVideoPlayerView
//
//  Created by Andrei-Sergiu Pițiș on 12/04/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerControlsTests: ASPTestCase {
	
	let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testInitPlayerControler_ShouldSetWeakReferenceToVideoPlayer() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		XCTAssertEqual(sut.videoPlayer, videoPlayer, "Players are equal.")
	}
	
	func testSetNextButtonHidden_ShouldHideNextButton() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.nextButtonHidden = true
		
		XCTAssertEqual(sut.nextButtonHidden, true, "Next button is not hidden.")
	}
	
	func testSetPreviousButtonHidden_ShouldHidePreviousButton() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.previousButtonHidden = true
		
		XCTAssertEqual(sut.previousButtonHidden, true, "Next button is not hidden.")
	}
	
	func testSetInteracting_ShouldCallInteractingClosure() {
        let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.interacting = { (isInteracting) in
			XCTAssertTrue(isInteracting, "Interacting is false.")
			expectation.fulfill()
		}
		
		sut.isInteracting = true
        
        asp_waitForExpectations()
	}
	
	func testApplicationDidEnterBackgroundReceived_ShouldPauseVideo() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.play()

		NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		
		XCTAssertEqual(sut.videoPlayer?.status, .paused, "Video is not paused.")
	}
	
	func testVideoStoppedAndPlayButtonPressed_ShouldPlayVideo() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.playButtonPressed()
		
		XCTAssertEqual(sut.videoPlayer?.status, .playing, "Video is not playing.")
	}
	
	func testVideoPlayingAndPlayButtonPressed_ShouldPauseVideo() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.play()
		
		sut.playButtonPressed()
		
		XCTAssertEqual(sut.videoPlayer?.status, .paused, "Video is not paused.")
	}
	
	func testNextButtonPressed_DidPressNextButton() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.didPressNextButton = {
			expectation.fulfill()
		}
		
		sut.nextButtonPressed()
		
		asp_waitForExpectations()
	}
	
	func testPreviousButtonPressed_DidPressPreviousButton() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.didPressPreviousButton = {
			expectation.fulfill()
		}
		
		sut.previousButtonPressed()
		
		asp_waitForExpectations()
	}
	
	func testProgressSliderBeginTouch_ShouldSetInteraction() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.interacting = { (isInteracting) in
			XCTAssertTrue(isInteracting, "Interacting is false.")
			expectation.fulfill()
		}
		
		sut.progressSliderBeginTouch()
		
		asp_waitForExpectations()
	}
	
	func testProgressSliderEndTouch_ShouldSetInteraction() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		let slider = Scrubber()
		slider.value = 0.5
		
		sut.progressSliderChanged(slider: slider)
		
		XCTAssertEqual(sut.videoPlayer?.progress, Double(slider.value), "Values are not equal.")
	}
	
	func testPlayCalled_ShoudStartVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.play()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
	}
	
	func testPauseCalled_ShouldPauseVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.pause()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.paused, "Video is paused.")
	}
	
	func testStopCalled_ShouldStopVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.stop()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.stopped, "Video is stopped.")
	}
 
	func testJumpForwardCalled_ShouldJumpVideoPlaybackForward() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.readyToPlayVideo = { [weak videoPlayer] in
			videoPlayer?.seek(0.5)
			let initialProgress = videoPlayer?.progress
			
			sut.jumpForward()
			
			XCTAssertGreaterThan(sut.videoPlayer?.progress ?? 0, initialProgress!, "Video jumped forwards.")
			expectation.fulfill()
		}
		
		asp_waitForExpectations()
	}
	
	func testJumpBackwardCalled_ShouldJumpVideoPlaybackBackward() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.readyToPlayVideo = { [weak videoPlayer] in
			videoPlayer?.seek(0.5)
			let initialProgress = videoPlayer?.progress
			
			sut.jumpBackward()
			
			XCTAssertLessThan(sut.videoPlayer?.progress ?? 1, initialProgress!, "Video jumped backwards.")
			expectation.fulfill()
		}
		
		asp_waitForExpectations()
	}
	
	func testVolumeSet_ShouldChangeVolumeToNewValue () {
        let expectation = self.asp_expectation(description: #function)
        
        let videoPlayer = ASPVideoPlayerView()
        let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
        
        videoPlayer.readyToPlayVideo = {
            sut.volume(0.5)
            
            XCTAssertEqual(sut.videoPlayer?.volume, 0.5, "Video volume set.")
            expectation.fulfill()
        }
        
        videoPlayer.videoURL = self.videoURL
        
        asp_waitForExpectations()
	}
	
	func testSeekToSpecificLocation_ShouldSeekVideoToPercentage() {
		let expectation = self.asp_expectation(description: #function)
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		let minimumValue = 0.0
		let maximumValue = 3.0
		let value = 1.5
		
		videoPlayer.seekEnded = {
			let progress = sut.videoPlayer?.progress
			
			XCTAssertEqual(progress, 0.5, "Video set to specified percentage.")
			expectation.fulfill()
		}
		
		videoPlayer.readyToPlayVideo = {
			sut.seek(min: minimumValue, max: maximumValue, value: value)
		}
		
		asp_waitForExpectations()
	}
}
