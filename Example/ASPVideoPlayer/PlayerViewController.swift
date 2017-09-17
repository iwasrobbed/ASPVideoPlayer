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
			  let firstNetworkURL = Bundle.main.url(forResource: "video", withExtension: "mp4") // URL(string: "https://d2js9x33ub8wlt.cloudfront.net/lessons/SharpeningAndHoning/HoldingKnivesRollingOff.mp4")
			else { return }
		
		videoPlayer.videoURL = firstNetworkURL
		videoPlayer.videoPlayerView?.gravity = .aspectFit
		videoPlayer.videoPlayerControls?.timeFont = UIFont.systemFont(ofSize: 12)
		videoPlayer.videoPlayerView?.startPlayingWhenReady = true
	}
	
}
