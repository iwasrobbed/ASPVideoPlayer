//
//  PlayerViewController.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 09/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASPVideoPlayer

class PlayerViewController: UIViewController {
	
	@IBOutlet weak var videoPlayer: ASPVideoPlayer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        guard let videoPlayer = videoPlayer,
              let firstLocalVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4"),
              let secondLocalVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4"),
              let firstNetworkURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"),
              let secondNetworkURL = URL(string: "http://www.easy-fit.ae/wp-content/uploads/2014/09/WebsiteLoop.mp4")
        else { return }
        
		videoPlayer.videoURLs = [firstLocalVideoURL, secondLocalVideoURL, firstNetworkURL, secondNetworkURL]
		videoPlayer.videoPlayerView?.gravity = .aspectFit
		videoPlayer.videoPlayerView?.shouldLoop = true
        videoPlayer.videoPlayerControls?.timeFont = UIFont.systemFont(ofSize: 12)
	}
	
}
