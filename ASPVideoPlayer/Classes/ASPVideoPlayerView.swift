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
@available(iOS 10.0, *)
@IBDesignable open class ASPVideoPlayerView: UIView {
    
    //MARK: - Type definitions -
    
    /**
     Void closure type.
     */
    public typealias VoidClosure = () -> ()
    
    /**
     Count closure type.
     - Parameter count: The count of the item (e.g. loop count)
     */
    public typealias CountClosure = (_ count: Int) -> ()
    
    /**
     Closure type for recurring actions.
     - Parameter progress: The progress indicator value. Value is in range [0.0, 1.0].
     */
    public typealias ProgressClosure = (_ progress: Double) -> ()
    
    /**
     Closure type for error handling.
     - Parameter error: The error that occured.
     */
    public typealias ErrorClosure = (_ error: NSError) -> ()
    
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
     Enqueues a closure that will be called when a new video is loaded.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var newVideo: VoidClosure? {
        didSet {
            guard let closure = newVideo else {
                newVideoClosures.removeAll()
                return
            }
            newVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when the video is ready to play.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var readyToPlayVideo: VoidClosure? {
        didSet {
            guard let closure = readyToPlayVideo else {
                readyToPlayVideoClosures.removeAll()
                return
            }
            readyToPlayVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is started.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var startedVideo: VoidClosure? {
        didSet {
            guard let closure = startedVideo else {
                startedVideoClosures.removeAll()
                return
            }
            startedVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called repeatedly while the video is playing.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var playingVideo: ProgressClosure? {
        didSet {
            guard let closure = playingVideo else {
                playingVideoClosures.removeAll()
                return
            }
            playingVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is buffering.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var bufferingVideo: VoidClosure? {
        didSet {
            guard let closure = bufferingVideo else {
                bufferingVideoClosures.removeAll()
                return
            }
            bufferingVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is finished buffering.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var bufferingVideoFinished: VoidClosure? {
        didSet {
            guard let closure = bufferingVideoFinished else {
                bufferingVideoFinishedClosures.removeAll()
                return
            }
            bufferingVideoFinishedClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is paused.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var pausedVideo: VoidClosure? {
        didSet {
            guard let closure = pausedVideo else {
                pausedVideoClosures.removeAll()
                return
            }
            pausedVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is looped (since `finishedVideo` won't be called for this event).
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var loopedVideo: CountClosure? {
        didSet {
            guard let closure = loopedVideo else {
                loopedVideoClosures.removeAll()
                return
            }
            loopedVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when the end of the video has been reached.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var finishedVideo: VoidClosure? {
        didSet {
            guard let closure = finishedVideo else {
                finishedVideoClosures.removeAll()
                return
            }
            finishedVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a video is stopped.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var stoppedVideo: VoidClosure? {
        didSet {
            guard let closure = stoppedVideo else {
                stoppedVideoClosures.removeAll()
                return
            }
            stoppedVideoClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a seek is triggered.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var seekStarted: VoidClosure? {
        didSet {
            guard let closure = seekStarted else {
                seekStartedClosures.removeAll()
                return
            }
            seekStartedClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when a seek has ended.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var seekEnded: VoidClosure? {
        didSet {
            guard let closure = seekEnded else {
                seekEndedClosures.removeAll()
                return
            }
            seekEndedClosures.append(closure)
        }
    }
    
    /**
     Enqueues a closure that will be called when an error occured.
     
     Note: a `nil` value will clear all enqueued closures of this type.
     */
    open var error: ErrorClosure? {
        didSet {
            guard let closure = error else {
                errorClosures.removeAll()
                return
            }
            errorClosures.append(closure)
        }
    }
    
    //MARK: - Public Variables -
    
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
        guard let urlAsset = currentVideoItem?.asset as? AVURLAsset else { return nil }
        
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
            
            // Important: you must disable looping (and stop video) or you'll get obscure crashes
            stopVideo()
            removeObservers()
            
            // Asynchronously load the item and get it ready for playing
            loadAsset(for: url) { [weak self] playerItem in
                guard let strongSelf = self, let item = playerItem else { return }
                
                strongSelf.currentVideoItem = item
                let queuePlayer = AVQueuePlayer(playerItem: item)
                strongSelf.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                strongSelf.videoPlayerLayer.player = queuePlayer
                strongSelf.videoPlayerLayer.player?.rate = 0.0
                strongSelf.videoPlayerLayer.videoGravity = strongSelf.videoGravity
                
                strongSelf.addKVObservers(to: item)
                strongSelf.notifyOfNewVideo()
            }
        }
    }
    
    /**
     The gravity of the video. Adjusts how the video fills the space of the container.
     */
    open var gravity: PlayerContentMode = .aspectFill {
        didSet {
            switch gravity {
            case .aspectFill:
                videoGravity = AVLayerVideoGravity.resizeAspectFill
            case .aspectFit:
                videoGravity = AVLayerVideoGravity.resizeAspect
            case .resize:
                videoGravity = AVLayerVideoGravity.resize
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
        if let time = currentVideoItem?.currentTime() {
            return time.seconds
        }
        
        return 0.0
    }
    
    /**
     The length of the video in seconds.
     */
    open var videoLength: Double {
        if let duration = currentVideoItem?.asset.duration {
            return duration.seconds
        }
        
        return 0.0
    }
    
    fileprivate(set) var progress: Double = 0.0
    
    //MARK: - Private Variables and Constants -
    
    private var newVideoClosures = [VoidClosure]()
    private var readyToPlayVideoClosures = [VoidClosure]()
    private var startedVideoClosures = [VoidClosure]()
    private var playingVideoClosures = [ProgressClosure]()
    private var bufferingVideoClosures = [VoidClosure]()
    private var bufferingVideoFinishedClosures = [VoidClosure]()
    private var pausedVideoClosures = [VoidClosure]()
    private var loopedVideoClosures = [CountClosure]()
    private var finishedVideoClosures = [VoidClosure]()
    private var stoppedVideoClosures = [VoidClosure]()
    private var seekStartedClosures = [VoidClosure]()
    private var seekEndedClosures = [VoidClosure]()
    private var errorClosures = [ErrorClosure]()
    
    private var currentVideoItem: AVPlayerItem?
    private var looper: AVPlayerLooper?
    
    private lazy var videoPlayerLayer: AVPlayerLayer = { [unowned self] in
        let layer = AVPlayerLayer()
        layer.videoGravity = self.videoGravity
        return layer
    }()
    
    private var animationForwarder: AnimationForwarder?
    
    private var videoGravity = AVLayerVideoGravity.resizeAspectFill
    
    private var timeObserver: AnyObject?
    
    // KVO has no way of checking if an observer has been added so we can
    // then safely remove it, so this is an alternative way
    private var addedKVObservers = false
    
    private let statusKey = "status"
    private let playbackBufferEmptyKey = "playbackBufferEmpty"
    private let playbackLikelyToKeepUpKey = "playbackLikelyToKeepUp"
    private var kvoContext = "AVPlayerItemContext"
    
    private let loopCount = "loopCount"
    
    private let assetTracksKey = "tracks"
    private let assetPlayableKey = "playable"
    private let assetDurationKey = "duration"
    
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
        
        if layer.sublayers == nil || layer.sublayers?.contains(videoPlayerLayer) == false {
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
        notifyOfStartedVideo()
        
        NotificationCenter.default.removeObserver(self)
        if let currentItem = currentVideoItem {
            addNotificationObservers(to: currentItem)
        }
    }
    
    /**
     Pauses the video.
     */
    open func pauseVideo() {
        videoPlayerLayer.player?.rate = 0.0
        status = .paused
        notifyOfPausedVideo()
    }
    
    /**
     Stops the video.
     */
    open func stopVideo() {
        // Important: you must disable looping or you'll get obscure crashes
        looper?.disableLooping()
        
        videoPlayerLayer.player?.rate = 0.0
        seekToZero()
        status = .stopped
        notifyOfStoppedVideo()
    }
    
    /**
     Seek to specific position in video. Should be a value in the range [0.0, 1.0].
     */
    open func seek(_ percentage: Double) {
        progress = min(1.0, max(0.0, percentage))
        if let currentItem = currentVideoItem {
            if progress == 0.0 {
                seekToZero()
                notifyOfPlayingVideo(progress)
            } else {
                let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
                videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [weak self] (finished) in
                    guard let strongSelf = self else { return }
                    if finished == false {
                        strongSelf.notifyOfSeekStarted()
                    } else {
                        strongSelf.notifyOfSeekEnded()
                        strongSelf.notifyOfPlayingVideo(strongSelf.progress)
                    }
                })
            }
        }
    }
    
    //MARK: - KeyValueObserving methods -
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvoContext,
              let aspKeyPath = keyPath
            else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
        }
        
        if let item = object as? AVPlayerItem {
            switch aspKeyPath {
            case statusKey:
                handleStatusChange(for: item)
            case playbackBufferEmptyKey:
                notifyOfBufferingVideo()
            case playbackLikelyToKeepUpKey:
                notifyOfBufferingVideoFinished()
            default:
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        } else if let looper = object as? AVPlayerLooper, aspKeyPath == loopCount {
            notifyOfLoopedVideo(looper.loopCount)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func addKVObservers(to item: AVPlayerItem?) {
        guard addedKVObservers == false, let item = item else { return }
        item.addObserver(self, forKeyPath: statusKey, options: [], context: &kvoContext)
        item.addObserver(self, forKeyPath: playbackBufferEmptyKey, options: [], context: &kvoContext)
        item.addObserver(self, forKeyPath: playbackLikelyToKeepUpKey, options: [], context: &kvoContext)
        
        looper?.addObserver(self, forKeyPath: loopCount, options: [], context: &kvoContext)
        
        addedKVObservers = true
    }
    
    fileprivate func removeKVObservers() {
        guard addedKVObservers, let currentItem = currentVideoItem else { return }
        currentItem.removeObserver(self, forKeyPath: statusKey)
        currentItem.removeObserver(self, forKeyPath: playbackBufferEmptyKey)
        currentItem.removeObserver(self, forKeyPath: playbackLikelyToKeepUpKey)
        
        looper?.removeObserver(self, forKeyPath: loopCount)
        
        addedKVObservers = false
    }
    
    fileprivate func handleStatusChange(for item: AVPlayerItem) {
        guard let currentItem = currentVideoItem, currentItem == item else { return }
        
        if item.status == .readyToPlay {
            if status == .new {
                status = .readyToPlay
            }
            addTimeObserver()
            
            if startPlayingWhenReady == true {
                playVideo()
            } else {
                notifyOfReadyToPlayVideo()
            }
        } else if item.status == .failed {
            generateError(message: "Error loading video.")
        }
    }
    
    //MARK: - Private methods -
    
    fileprivate func loadAsset(for url: URL, completion: @escaping ((_ item: AVPlayerItem?) -> Void)) {
        let asset = AVAsset(url: url)
        let keys = [assetTracksKey, assetPlayableKey, assetDurationKey]
        
        asset.loadValuesAsynchronously(forKeys: keys, completionHandler: { [weak self] in
            DispatchQueue.main.sync(execute: {
                guard let strongSelf = self else {
                    completion(nil)
                    return
                }
                
                keys.forEach {
                    var error: NSError?
                    let status = asset.statusOfValue(forKey: $0, error:&error)
                    if status == .failed {
                        strongSelf.generateError(message: "Asset failed to load from url. Error: \(String(describing: error))")
                        completion(nil)
                        return
                    }
                }
                
                guard asset.isPlayable else {
                    strongSelf.generateError(message: "Asset is not playable after loading from url.")
                    completion(nil)
                    return
                }
                
                completion(AVPlayerItem(asset: asset))
            })
        })
    }
    
    fileprivate func generateError(message: String) {
        status = .error
        
        let userInfo = [NSLocalizedDescriptionKey: message]
        let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
        
        notifyOfError(videoError)
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
            guard let strongSelf = self , strongSelf.status == .playing else { return }
            
            let currentTime = time.seconds
            strongSelf.progress = currentTime / (strongSelf.videoLength != 0.0 ? strongSelf.videoLength : 1.0)
            
            strongSelf.notifyOfPlayingVideo(strongSelf.progress)
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
              let currentItem = currentVideoItem,
              notificationItem == currentItem
            else { return }
        
        notifyOfFinishedVideo()
    }
    
    @objc internal func itemFailedToPlayToEndTime(_ notification: Notification) {
        let errorMessage = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        generateError(message: "Playback of the video failed. Error: \(String(describing: errorMessage))")
    }
    
    //MARK: - Closure notifications -
    
    fileprivate func notifyOfNewVideo() {
        status = .new
        newVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfReadyToPlayVideo() {
        readyToPlayVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfStartedVideo() {
        startedVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfPlayingVideo(_ progress: Double) {
        playingVideoClosures.forEach({ $0(progress) })
    }
    
    fileprivate func notifyOfBufferingVideo() {
        bufferingVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfBufferingVideoFinished() {
        bufferingVideoFinishedClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfPausedVideo() {
        pausedVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfLoopedVideo(_ count: Int) {
        loopedVideoClosures.forEach({ $0(count) })
    }
    
    fileprivate func notifyOfFinishedVideo() {
        finishedVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfStoppedVideo() {
        stoppedVideoClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfSeekStarted() {
        seekStartedClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfSeekEnded() {
        seekEndedClosures.forEach({ $0() })
    }
    
    fileprivate func notifyOfError(_ error: NSError) {
        errorClosures.forEach({ $0(error) })
    }

}
