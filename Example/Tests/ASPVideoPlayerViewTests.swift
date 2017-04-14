//
//  ASPVideoPlayerViewTests.swift
//  ASPVideoPlayerViewTests
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerViewTests: ASPTestCase {
    
    let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
    let secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")!
    let invalidVideoURL = Bundle.main.url(forResource: "video3", withExtension: "mp4")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithFrame_ShouldCreatePlayerWithFrame() {
        let frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        let player = ASPVideoPlayerView(frame: frame)
        
        XCTAssertEqual(player.frame, frame, "Frames are equal.")
    }
    
    func testDeinitCalled_ShouldDeallocatePlayer() {
        weak var player = ASPVideoPlayerView()
        
        XCTAssertNil(player, "Player deallocated.")
    }
    
    func testSetVolumeAboveMaximum_ShouldSetPlayerVolumeToMaximum() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.videoURL = self.videoURL
        
        player.readyToPlayVideo = { [weak player] in
            player?.volume = 2.0
            
            XCTAssertEqual(player?.volume, 1.0, "Video volume sets to maximum")
            expectation.fulfill()
        }
        
        asp_waitForExpectations()
    }
    
    func testSetVolumeBelowMinimum_ShouldSetPlayerVolumeToMinimum() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.videoURL = self.videoURL
        
        player.readyToPlayVideo = { [weak player] in
            player?.volume = -1.0
            
            XCTAssertEqual(player?.volume, 0.0, "Video volume sets to minimum")
            expectation.fulfill()
        }
        
        asp_waitForExpectations()
    }
    
    func testSetVolumeURLNotSet_ShouldSetPlayerVolumeToMinimum() {
        let player = ASPVideoPlayerView()
        
        player.volume = -1.0
        
        XCTAssertEqual(player.volume, 0.0, "Volume set to minimum.")
    }
    
    func testSetGravityAspectFill_ShouldChangeGravityToAspectFill() {
        let player = ASPVideoPlayerView()
        
        player.gravity = .aspectFill
        
        XCTAssertEqual(player.gravity, ASPVideoPlayerView.PlayerContentMode.aspectFill, "Content Mode is AspectFill.")
    }
    
    func testSetGravityResize_ShouldChangeGravityToResize() {
        let player = ASPVideoPlayerView()
        
        player.gravity = .resize
        
        XCTAssertEqual(player.gravity, ASPVideoPlayerView.PlayerContentMode.resize, "Content Mode is Resize.")
    }
    
    func testLoadInvalidURL_ShouldChangeStateToError() {
        let player = ASPVideoPlayerView()
        player.error = { [weak player] (error) in
            XCTAssertNil(player?.videoURL, "Video URL is nil.")
            XCTAssertEqual(error.localizedDescription, "Video URL is invalid (can't be nil).")
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.error)
        }
        player.videoURL = invalidVideoURL
    }
    
    func testLoadInvalidURL_ShouldReturnZeroForCurrentTime() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        
        player.error = { [weak player] error in
            XCTAssertEqual(player?.currentTime, 0.0, "Current Time is Zero")
            expectation.fulfill()
        }
        
        player.videoURL = invalidVideoURL
        
        asp_waitForExpectations()
    }
    
    func testLoadInvalidURL_ShouldReturnZeroForVideoLength() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        
        player.error = { [weak player] error in
            XCTAssertEqual(player?.videoLength, 0.0, "Video Length is Zero")
            expectation.fulfill()
        }
        
        player.videoURL = invalidVideoURL
        
        asp_waitForExpectations()
    }
    
    func testLoadVideoURL_ShouldLoadVideoAtURL() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.newVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.new)
            XCTAssertNotNil(player?.videoURL, "Video URL is not nil.")
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testLoadNewVideoURL_ShouldLoadVideoAtURL() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        
        player.readyToPlayVideo = { [weak player] in
            player?.newVideo = {
                XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.new)
                XCTAssertEqual(player?.videoURL, self.secondVideoURL)
                expectation.fulfill()
            }
            
            player?.videoURL = self.secondVideoURL
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testLoadVideoAndStartPlayingWhenReadySet_ShouldChangeStateToPlaying() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        
        player.startPlayingWhenReady = true
        
        player.startedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testSeekToPercentageBelowMinimum_ShouldSetCurrentTimeToZero() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.readyToPlayVideo = { [weak player] in
            player?.seek(-1.0)
            player?.pauseVideo()
        }
        
        player.pausedVideo = { [weak player] in
            XCTAssertEqual(player?.currentTime, 0.0, "Current Time is Zero")
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testPlayVideo_ShouldStartVideoPlayback() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.startPlayingWhenReady = true
        
        player.playingVideo = { [weak player] (progress) in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            player?.stopVideo()
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testPlayVideoThatIsAtMaximumPercentage_ShouldStartVideoPlaybackFromStartOfVideo() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.readyToPlayVideo = { [weak player] in
            player?.seek(1.0)
            player?.playVideo()
        }
        
        player.startedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            XCTAssertEqual(player?.progress, 0.0, "Progress is Zero")
            
            player?.stopVideo()
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testPlayFinishedVideo_ShouldStartVideoPlaybackFromBeginning() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.readyToPlayVideo = { [weak player] in
            player?.playingVideo = { (progress) in
                XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
                player?.stopVideo()
                expectation.fulfill()
            }
            
            player?.playVideo()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testStopVideo_ShouldStopVideo() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.startPlayingWhenReady = true
        
        player.playingVideo = { [weak player] (progress) in
            player?.stopVideo()
        }
        
        player.stoppedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.stopped, "Video playback has stopped.")
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations()
    }
    
    func testShouldLoopSet_ShouldLoopVideoWhenFinished() {
        let expectation = self.asp_expectation(description: #function)
        
        let player = ASPVideoPlayerView()
        player.shouldLoop = true
        player.startPlayingWhenReady = true
        
        player.finishedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            expectation.fulfill()
        }
        
        player.videoURL = videoURL
        
        asp_waitForExpectations(timeout: 20)
    }
}
