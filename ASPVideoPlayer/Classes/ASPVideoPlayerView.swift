//
//  ASPVideoPlayer.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/**
A simple UIView subclass that can play a video and allows animations to be applied during playback.
*/
@IBDesignable open class ASPVideoPlayerView: UIView {
	
	//MARK: - Type definitions -
	
	/**
	Basic closure type.
	*/
	public typealias VoidClosure = (() -> Void)?
	
	/**
	Closure type for recurring actions.
	- Parameter progress: The progress indicator value. Value is in range [0.0, 1.0].
	*/
	public typealias ProgressClosure = ((_ progress: Double) -> Void)?
	
	/**
	Closure type for error handling.
	- Parameter error: The error that occured.
	*/
	public typealias ErrorClosure = ((_ error: NSError) -> Void)?
	
	//MARK: - Enumerations -
	
	/**
	Specifies how the video is displayed within a player layer’s bounds.
	*/
	public enum PlayerContentMode {
		case aspectFill
		case aspectFit
		case resize
	}
	
	/**
	Specifies the current status of the player.
	*/
	public enum PlayerStatus {
		/**
		A new video has been assigned.
		*/
		case new
		/**
		The video is ready to be played.
		*/
		case readyToPlay
		/**
		The video is currently being played.
		*/
		case playing
        /**
        The video is buffering.
        */
        case buffering
		/**
		The video has been paused.
		*/
		case paused
		/**
		The video playback has been stopped.
		*/
		case stopped
		/**
		An error occured. For more details use the `error` closure.
		*/
		case error
	}
	
	//MARK: - Closures -
	
	/**
	A closure that will be called when a new video is loaded.
	*/
	open var newVideo: VoidClosure
	
	/**
	A closure that will be called when the video is ready to play.
	*/
	open var readyToPlayVideo: VoidClosure
	
	/**
	A closure that will be called when a video is started.
	*/
	open var startedVideo: VoidClosure
	
	/**
	A closure that will be called repeatedly while the video is playing.
	*/
	open var playingVideo: ProgressClosure
    
    /**
    A closure that will be called when a video is buffering.
     */
    open var bufferingVideo: VoidClosure
    
    /**
    A closure that will be called when a video is finished buffering.
     */
    open var bufferingVideoFinished: VoidClosure
	
	/**
	A closure that will be called when a video is paused.
	*/
	open var pausedVideo: VoidClosure
	
	/**
	A closure that will be called when the end of the video has been reached.
	*/
	open var finishedVideo: VoidClosure
	
	/**
	A closure that will be called when a video is stopped.
	*/
	open var stoppedVideo: VoidClosure
	
	/**
	A closure that will be called when a seek is triggered.
	*/
	open var seekStarted: VoidClosure
	
	/**
	A closure that will be called when a seek has ended.
	*/
	open var seekEnded: VoidClosure
	
	/**
	A closure that will be called when an error occured.
	*/
	open var error: ErrorClosure
	
	//MARK: - Public Variables -
	
	/**
	Sets whether the video should loop.
	*/
	open var shouldLoop: Bool = false
	
	/**
	Sets whether the video should start automatically after it has been successfuly loaded.
	*/
	open var startPlayingWhenReady: Bool = false
	
	/**
	The current status of the video player.
	*/
	open fileprivate(set) var status: PlayerStatus = .new
	
    /**
    The url of the currently playing video.
     */
    open var currentVideoURL: URL? {
        guard let urlAsset = videoPlayerLayer.player?.currentItem?.asset as? AVURLAsset else { return nil }
        
        return urlAsset.url
    }
    
	/**
	The url of the video that should be loaded.
	*/
	open var videoURL: URL? = nil {
		didSet {
            guard let url = videoURL else {
                generateError(message: "Video URL is invalid (can't be nil).")
                return
            }
            
            videoURLs = [url]
		}
	}
    
    /**
    The urls of the videos that should be loaded.
     */
    open var videoURLs: [URL]? = nil {
        didSet {
            guard let urls = videoURLs else {
                generateError(message: "Video URLs are invalid (can't be nil).")
                return
            }
            
            removeObservers()
            
            videoItems = urls.map({ AVPlayerItem(url: $0) })
            let firstItem = videoItems.first
            videoPlayerLayer.player = AVQueuePlayer(playerItem: firstItem)
            videoPlayerLayer.player?.rate = 0.0
            videoPlayerLayer.videoGravity = videoGravity
            
            addKVObservers(to: firstItem)
            notifyOfNewVideo()
        }
    }
	
	/**
	The gravity of the video. Adjusts how the video fills the space of the container.
	*/
	open var gravity: PlayerContentMode = .aspectFill {
		didSet {
			switch gravity {
			case .aspectFill:
				videoGravity = AVLayerVideoGravityResizeAspectFill
			case .aspectFit:
				videoGravity = AVLayerVideoGravityResizeAspect
			case .resize:
				videoGravity = AVLayerVideoGravityResize
			}
			
			videoPlayerLayer.videoGravity = videoGravity
		}
	}
	
	/**
	The volume of the player. Should be a value in the range [0.0, 1.0].
	*/
	open var volume: Float {
		set {
			let value = min(1.0, max(0.0, newValue))
			videoPlayerLayer.player?.volume = value
		}
		get {
			return videoPlayerLayer.player?.volume ?? 0.0
		}
	}
	
	/**
	The current playback time in seconds.
	*/
	open var currentTime: Double {
		if let time = videoPlayerLayer.player?.currentItem?.currentTime() {
			return time.seconds
		}
		
		return 0.0
	}
	
	/**
	The length of the video in seconds.
	*/
	open var videoLength: Double {
		if let duration = videoPlayerLayer.player?.currentItem?.asset.duration {
			return duration.seconds
		}
		
		return 0.0
	}
	
	fileprivate(set) var progress: Double = 0.0
	
	//MARK: - Private Variables and Constants -
    
    private var videoItems = [AVPlayerItem]()
    
    private var currentVideoIndex: Int? {
        guard let currentItem = videoPlayerLayer.player?.currentItem else { return nil }
        
        return videoItems.index(of: currentItem)
    }
	
	private let videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
	
	private var animationForwarder: AnimationForwarder!
	
	private var videoGravity: String! = AVLayerVideoGravityResizeAspectFill
	
	private var timeObserver: AnyObject?
    
    private let statusKey = "status"
    private let playbackBufferEmptyKey = "playbackBufferEmpty"
    private let playbackLikelyToKeepUpKey = "playbackLikelyToKeepUp"
    private var kvoContext = "AVPlayerItemContext"
	
	//MARK: - Superclass methods -
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	open override var frame: CGRect {
		didSet {
			videoPlayerLayer.frame = bounds
		}
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		if layer.sublayers == nil || !layer.sublayers!.contains(videoPlayerLayer) {
			layer.addSublayer(videoPlayerLayer)
			animationForwarder = AnimationForwarder(view: self)
			videoPlayerLayer.delegate = animationForwarder
		}
		
		videoPlayerLayer.frame = bounds
	}
	
	deinit {
		removeObservers()
	}
	
	//MARK: - Public methods -
	
	/**
	Starts the video player from the beginning.
	*/
	open func playVideo() {
		if progress >= 1.0 {
			seekToZero()
		}
		
		status = .playing
		videoPlayerLayer.player?.rate = 1.0
		startedVideo?()
		
		NotificationCenter.default.removeObserver(self)
		if let currentItem = videoPlayerLayer.player?.currentItem {
            addNotificationObservers(to: currentItem)
		}
	}
	
	/**
	Pauses the video.
	*/
	open func pauseVideo() {
		videoPlayerLayer.player?.rate = 0.0
		status = .paused
		pausedVideo?()
	}
    
    /**
    Starts the previous video in the queue from the beginning.
     */
    open func playPreviousVideo() {
        guard let currentVideoIndex = currentVideoIndex else { return }
        
        let previousVideoIndex = (currentVideoIndex - 1 + videoItems.count) % videoItems.count
        skipToVideo(at: previousVideoIndex)
    }
    
    /**
    Starts the next video in the queue from the beginning.
     */
    open func playNextVideo() {
        guard let currentVideoIndex = currentVideoIndex else { return }
        
        let nextVideoIndex = (currentVideoIndex + 1) % videoItems.count
        skipToVideo(at: nextVideoIndex)
    }
	
	/**
	Stops the video.
	*/
	open func stopVideo() {
		videoPlayerLayer.player?.rate = 0.0
		seekToZero()
		status = .stopped
		stoppedVideo?()
	}
	
	/**
	Seek to specific position in video. Should be a value in the range [0.0, 1.0].
	*/
	open func seek(_ percentage: Double) {
		progress = min(1.0, max(0.0, percentage))
		if let currentItem = videoPlayerLayer.player?.currentItem {
			if progress == 0.0 {
				seekToZero()
				playingVideo?(progress)
			} else {
				let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
				videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
					if finished == false {
						self.seekStarted?()
					} else {
						self.seekEnded?()
						self.playingVideo?(self.progress)
					}
				})
			}
		}
	}
	
	//MARK: - KeyValueObserving methods -
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvoContext,
              let aspKeyPath = keyPath,
              let item = object as? AVPlayerItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch aspKeyPath {
        case statusKey:
            handleStatusChange(for: item)
        case playbackBufferEmptyKey:
            bufferingVideo?()
        case playbackLikelyToKeepUpKey:
            bufferingVideoFinished?()
        default:
           super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
	}
    
    fileprivate func addKVObservers(to item: AVPlayerItem?) {
        guard let item = item else { return }
        item.addObserver(self, forKeyPath: statusKey, options: [], context: &kvoContext)
        item.addObserver(self, forKeyPath: playbackBufferEmptyKey, options: [], context: &kvoContext)
        item.addObserver(self, forKeyPath: playbackLikelyToKeepUpKey, options: [], context: &kvoContext)
    }
    
    fileprivate func removeKVObservers() {
        guard let currentItem = videoPlayerLayer.player?.currentItem else { return }
        currentItem.removeObserver(self, forKeyPath: statusKey)
        currentItem.removeObserver(self, forKeyPath: playbackBufferEmptyKey)
        currentItem.removeObserver(self, forKeyPath: playbackLikelyToKeepUpKey)
    }
    
    fileprivate func handleStatusChange(for item: AVPlayerItem) {
        if item.status == .readyToPlay {
            if status == .new {
                status = .readyToPlay
            }
            addTimeObserver()
            
            if startPlayingWhenReady == true {
                playVideo()
            } else {
                readyToPlayVideo?()
            }
        } else if item.status == .failed {
            generateError(message: "Error loading video.")
        }
    }
	
	//MARK: - Private methods -
    
    fileprivate func generateError(message: String) {
        status = .error
        
        let userInfo = [NSLocalizedDescriptionKey: message]
        let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
        
        error?(videoError)
    }
	
	fileprivate func seekToZero() {
		progress = 0.0
		let time = CMTime(seconds: 0.0, preferredTimescale: 1)
		videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
	}
	
	fileprivate func addTimeObserver() {
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
		}
		
		timeObserver = videoPlayerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time) in
			guard let weakSelf = self , self?.status == .playing else { return }
			
			let currentTime = time.seconds
			weakSelf.progress = currentTime / (weakSelf.videoLength != 0.0 ? weakSelf.videoLength : 1.0)
			
			weakSelf.playingVideo?(weakSelf.progress)
		}) as AnyObject?
	}
    
    fileprivate func addNotificationObservers(to item: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)) , name: .AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(itemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: item)
    }
	
	fileprivate func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		removeKVObservers()
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
			timeObserver = nil
		}
	}
	
    @objc internal func itemDidFinishPlaying(_ notification: Notification) {
        guard let notificationItem = notification.object as? AVPlayerItem,
              let currentItem = videoPlayerLayer.player?.currentItem,
              notificationItem == currentItem else { return }
        
		finishedVideo?()
        
        if let lastVideoURL = videoURLs?.last, currentVideoURL != lastVideoURL {
            playNextVideo()
        } else if shouldLoop {
            loopFromBeginning()
        } else {
			stopVideo()
		}
	}
    
    @objc internal func itemFailedToPlayToEndTime(_ notification: Notification) {
        let errorMessage = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        generateError(message: "Playback of the video failed. Error: \(String(describing: errorMessage))")
    }
    
    fileprivate func skipToVideo(at index: Int) {
        guard index < videoItems.count, index >= 0 else {
                stopVideo()
                return
        }
        
        swapCurrentItem(for: videoItems[index])
    }
    
    fileprivate func loopFromBeginning() {
        guard let firstVideoItem = videoItems.first else { return }
        
        swapCurrentItem(for: firstVideoItem)
        playVideo()
    }
    
    fileprivate func swapCurrentItem(for newItem: AVPlayerItem) {
        guard let player = videoPlayerLayer.player as? AVQueuePlayer else { return }
        
        // Note: using an AVQueuePlayer in this way will allow for seamless looping;
        // using an AVPlayer by itself causes a flash of white/black in between loops
        removeKVObservers()
        if let currentItem = player.currentItem {
            player.remove(currentItem)
        }
        newItem.seek(to: kCMTimeZero)
        player.insert(newItem, after: nil)
        addKVObservers(to: newItem)
        notifyOfNewVideo()
    }
    
    fileprivate func notifyOfNewVideo() {
        status = .new
        newVideo?()
    }
}
