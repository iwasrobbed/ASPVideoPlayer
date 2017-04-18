//
//  ASPVideoPlayerControls.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 12/04/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/**
Protocol defining the player controls behaviour.
*/
public protocol VideoPlayerControls {
	/**
	Reference to the video player.
	*/
	weak var videoPlayer: ASPVideoPlayerView? {get set}
	
	/**
	The font for the time labels.
	*/
	var timeFont: UIFont? {get set}
	
	/**
	Starts the video playback.
	*/
	func play()
	
	/**
	Pauses the video playback.
	*/
	func pause()
	
	/**
	Stops the video playback.
	*/
	func stop()
	
	/**
	Jumps forward in the video playback.
	- Parameter value: The amount by which the current progress percentage will be increased.
	*/
	func jumpForward(_ value: Double)
	
	/**
	Jumps backwards in the video playback.
	- Parameter value: The amount by which the current progress percentage will be decreased.
	*/
	func jumpBackward(_ value: Double)
	
	/**
	Set the volume of the video.
	- Parameter value: The new volume value.
	*/
	func volume(_ value: Float)
}

/**
Protocol defining the player seek behaviour.
*/
public protocol VideoPlayerSeekControls {
	/**
	Reference to the video player.
	*/
	weak var videoPlayer: ASPVideoPlayerView? {get set}
	
	/**
	Set the new position in the video playback.
	- Parameter min: The minimum value of the used range.
	- Parameter max: The maximum value of the used range.
	- Parameter value: The value where the new video position should be, in the range [min, max].
	*/
	func seek(min: Double, max: Double, value: Double)
}

/**
Default implementation of the `VideoPlayerSeekControls` protocol.
*/
public extension VideoPlayerSeekControls {
	func seek(min: Double = 0.0, max: Double = 1.0, value: Double) {
		let value = rangeMap(value, min: min, max: max, newMin: 0.0, newMax: 1.0)
		videoPlayer?.seek(Double(value))
	}
}

/**
Default implementation of the `VideoPlayerControls` protocol.
*/
public extension VideoPlayerControls {
	func play() {
		videoPlayer?.playVideo()
	}
	
	func pause() {
		videoPlayer?.pauseVideo()
	}
	
	func stop() {
		videoPlayer?.stopVideo()
	}
	
	func jumpForward(_ value: Double = 0.05) {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage + value))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func jumpBackward(_ value: Double = 0.05) {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage - value))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func volume(_ value: Float) {
		videoPlayer?.volume = value
	}
}

/**
Base class for the video controls.
*/
open class ASPBasicControls: UIView, VideoPlayerControls, VideoPlayerSeekControls {
	
	//MARK: - Base class variables -
	
	@IBOutlet open weak var videoPlayer: ASPVideoPlayerView?
	
	public typealias VoidClosure = () -> ()
	public typealias BoolClosure = (Bool) -> ()
	
	open var didPressNextButton: VoidClosure? {
		didSet {
			guard let closure = didPressNextButton else {
				didPressNextButtonClosures.removeAll()
				return
			}
			didPressNextButtonClosures.append(closure)
		}
	}
	
	open var didPressPreviousButton: VoidClosure? {
		didSet {
			guard let closure = didPressPreviousButton else {
				didPressPreviousButtonClosures.removeAll()
				return
			}
			didPressPreviousButtonClosures.append(closure)
		}
	}
	
	open var interacting: BoolClosure? {
		didSet {
			guard let closure = interacting else {
				interactingClosures.removeAll()
				return
			}
			interactingClosures.append(closure)
		}
	}
	
	open var newVideo: VoidClosure? {
		didSet {
			guard let closure = newVideo else {
				newVideoClosures.removeAll()
				return
			}
			newVideoClosures.append(closure)
		}
	}
	
	open var startedVideo: VoidClosure? {
		didSet {
			guard let closure = startedVideo else {
				startedVideoClosures.removeAll()
				return
			}
			startedVideoClosures.append(closure)
		}
	}
	
	open var nextButtonHidden: Bool = true
	open var previousButtonHidden: Bool = true
	
	open var timeFont = UIFont(name: "Courier-Bold", size: 12.0)
	
	//MARK: - Base class private variables -
	
	fileprivate var didPressNextButtonClosures = [VoidClosure]()
	fileprivate var didPressPreviousButtonClosures = [VoidClosure]()
	fileprivate var interactingClosures = [BoolClosure]()
	fileprivate var newVideoClosures = [VoidClosure]()
	fileprivate var startedVideoClosures = [VoidClosure]()
}

@IBDesignable open class ASPVideoPlayerControls: ASPBasicControls {
	/**
	Reference to the video player. Can be set through the Interface Builder.
	*/
	@IBOutlet open override weak var videoPlayer: ASPVideoPlayerView? {
		didSet {
			setupVideoPlayerView()
		}
	}
	
	/**
	Sets the visibility of the next button.
	*/
	open override var nextButtonHidden: Bool {
		set {
			nextButton.isHidden = newValue
		}
		get {
			return nextButton.isHidden
		}
	}
	
	/**
	Sets the visibility of the previous button.
	*/
	open override var previousButtonHidden: Bool {
		set {
			previousButton.isHidden = newValue
		}
		get {
			return previousButton.isHidden
		}
	}
	
	/**
	Sets the color of the controls.
	*/
	open override var tintColor: UIColor? {
		didSet {
			playPauseButton.tintColor = tintColor
			nextButton.tintColor = tintColor
			previousButton.tintColor = tintColor
			progressLoader.tintColor = tintColor
			progressSlider.tintColor = tintColor
			
			lengthLabel.textColor = tintColor
			currentTimeLabel.textColor = tintColor
		}
	}
	
	/**
	The font for the time labels.
	*/
	open override var timeFont: UIFont? {
		didSet {
			currentTimeLabel.font = timeFont
			lengthLabel.font = timeFont
		}
	}
	
	//MARK: - Private Variables and Constants -
	
	private let playPauseButton = PlayPauseButton()
	private let progressSlider = Scrubber()
	private let nextButton = NextButton()
	private let previousButton = PreviousButton()
	private let progressLoader = Loader()
	
	private var currentTimeLabel = UILabel()
	private var lengthLabel = UILabel()
	
	@objc internal var isInteracting: Bool = false {
		didSet {
			notifyOfInteracting(isInteracting)
		}
	}
	
	//MARK: - Superclass methods -
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	convenience init(videoPlayer: ASPVideoPlayerView) {
		self.init(frame: CGRect.zero)
		self.videoPlayer = videoPlayer
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc internal func playButtonPressed() {
		if videoPlayer?.status == .playing {
			videoPlayer?.startPlayingWhenReady = false
			pause()
			
			isInteracting = true
		} else {
			videoPlayer?.startPlayingWhenReady = true
			play()
			
			isInteracting = false
		}
	}
	
	//MARK: - Private methods -
	
	@objc internal func nextButtonPressed() {
		isInteracting = false
		notifyOfDidPressNextButton()
	}
	
	@objc internal func previousButtonPressed() {
		isInteracting = false
		notifyOfDidPressPreviousButton()
	}
	
	@objc internal func progressSliderBeginTouch() {
		isInteracting = true
	}
	
	@objc internal func progressSliderChanged(slider: Scrubber) {
		seek(value: Double(slider.value))
		perform(#selector(setter: ASPVideoPlayerControls.isInteracting), with: false, afterDelay: 0.1)
	}
	
	@objc internal func applicationDidEnterBackground() {
		playPauseButton.isSelected = false
		pause()
	}
	
	private func setupVideoPlayerView() {
		guard let videoPlayerView = videoPlayer else { return }
		
		// Note: if you access `videoPlayerView` within itself below, 
		// it needs to be weakified first to avoid a retain cycle
		
		videoPlayerView.newVideo = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.notifyOfNewVideo()
			
			strongSelf.progressSlider.isUserInteractionEnabled = false
			
			strongSelf.progressLoader.startAnimating()
			strongSelf.progressSlider.value = 0.0
			
			strongSelf.lengthLabel.text = strongSelf.timeFormatted(totalSeconds: 0)
			strongSelf.currentTimeLabel.text = strongSelf.timeFormatted(totalSeconds: 0)
		}
		
		videoPlayerView.readyToPlayVideo = { [weak self, weak videoPlayerView] in
			guard let strongSelf = self, let strongVideoPlayerView = videoPlayerView else { return }
			
			strongSelf.progressSlider.isUserInteractionEnabled = true
			
			let currentTime = strongVideoPlayerView.currentTime
			strongSelf.lengthLabel.text = strongSelf.timeFormatted(totalSeconds: UInt(strongVideoPlayerView.videoLength))
			strongSelf.currentTimeLabel.text = strongSelf.timeFormatted(totalSeconds: UInt(currentTime))
			
			strongSelf.progressLoader.stopAnimating()
		}
		
		videoPlayerView.playingVideo = { [weak self, weak videoPlayerView] (progress) in
			guard let strongSelf = self, let strongVideoPlayerView = videoPlayerView else { return }
			
			if strongSelf.isInteracting == false {
				strongSelf.progressSlider.value = CGFloat(progress)
			}
			
			let currentTime = strongVideoPlayerView.currentTime
			strongSelf.currentTimeLabel.text = strongSelf.timeFormatted(totalSeconds: UInt(currentTime))
			strongSelf.progressLoader.stopAnimating()
		}
		
		videoPlayerView.bufferingVideo = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.progressLoader.startAnimating()
		}
		
		videoPlayerView.bufferingVideoFinished = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.progressLoader.stopAnimating()
		}
		
		videoPlayerView.startedVideo = { [weak self, weak videoPlayerView] in
			guard let strongSelf = self, let strongVideoPlayerView = videoPlayerView else { return }
			
			strongSelf.notifyOfStartedVideo()
			
			strongSelf.progressSlider.isUserInteractionEnabled = true
			strongSelf.playPauseButton.isSelected = true
			
			let currentTime = strongVideoPlayerView.currentTime
			strongSelf.lengthLabel.text = strongSelf.timeFormatted(totalSeconds: UInt(strongVideoPlayerView.videoLength))
			strongSelf.currentTimeLabel.text = strongSelf.timeFormatted(totalSeconds: UInt(currentTime))
			
			strongSelf.progressLoader.stopAnimating()
		}
		
		videoPlayerView.stoppedVideo = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.playPauseButton.isSelected = false
			strongSelf.progressSlider.value = 0.0
			strongSelf.progressLoader.stopAnimating()
		}
		
		videoPlayerView.error = { [weak self] (error) in
			guard let strongSelf = self else { return }
			
			strongSelf.progressLoader.stopAnimating()
			print(error)
		}
		
		videoPlayerView.seekStarted = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.progressLoader.startAnimating()
		}
		
		videoPlayerView.seekEnded = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.progressLoader.stopAnimating()
		}
	}
	
	private func timeFormatted(totalSeconds: UInt) -> String {
		let seconds = totalSeconds % 60
		let minutes = (totalSeconds / 60) % 60
		let hours = totalSeconds / 3600
		
		if hours != 0 {
			return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
		} else {
			return String(format: "%02d:%02d", minutes, seconds)
		}
	}
	
	private func commonInit() {
		NotificationCenter.default.addObserver(self, selector: #selector(ASPVideoPlayerControls.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		
		playPauseButton.translatesAutoresizingMaskIntoConstraints = false
		progressSlider.translatesAutoresizingMaskIntoConstraints = false
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		previousButton.translatesAutoresizingMaskIntoConstraints = false
		progressLoader.translatesAutoresizingMaskIntoConstraints = false
		currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		lengthLabel.translatesAutoresizingMaskIntoConstraints = false
		
		previousButton.isHidden = true
		nextButton.isHidden = true
		
		playPauseButton.backgroundColor = .clear
		playPauseButton.tintColor = tintColor
		
		progressSlider.tintColor = tintColor
		previousButton.tintColor = tintColor
		nextButton.tintColor = tintColor
		progressLoader.tintColor = tintColor
		
		currentTimeLabel.textColor = tintColor
		currentTimeLabel.textAlignment = .center
		currentTimeLabel.font = timeFont
		
		lengthLabel.textColor = tintColor
		lengthLabel.textAlignment = .center
		lengthLabel.font = timeFont
		
		playPauseButton.addTarget(self, action: #selector(ASPVideoPlayerControls.playButtonPressed), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(ASPVideoPlayerControls.nextButtonPressed), for: .touchUpInside)
		previousButton.addTarget(self, action: #selector(ASPVideoPlayerControls.previousButtonPressed), for: .touchUpInside)
		progressSlider.addTarget(self, action: #selector(ASPVideoPlayerControls.progressSliderChanged(slider:)), for: [.valueChanged])
		progressSlider.addTarget(self, action: #selector(ASPVideoPlayerControls.progressSliderBeginTouch), for: [.touchDown])
		
		addSubview(progressLoader)
		addSubview(playPauseButton)
		addSubview(progressSlider)
		addSubview(nextButton)
		addSubview(previousButton)
		addSubview(currentTimeLabel)
		addSubview(lengthLabel)
		
		setupLayout()
	}
	
	private func setupLayout() {
		let viewsDictionary: [String : Any] = ["playPauseButton":playPauseButton,
		                                       "progressSlider":progressSlider,
		                                       "nextButton":nextButton,
		                                       "previousButton":previousButton,
		                                       "progressLoader":progressLoader,
		                                       "currentTimeLabel":currentTimeLabel,
		                                       "lengthLabel":lengthLabel]
		
		var constraintsArray = [NSLayoutConstraint]()
		
		constraintsArray.append(NSLayoutConstraint(item: playPauseButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		constraintsArray.append(NSLayoutConstraint(item: playPauseButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		
		constraintsArray.append(NSLayoutConstraint(item: nextButton, attribute: .centerY, relatedBy: .equal, toItem: playPauseButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		constraintsArray.append(NSLayoutConstraint(item: previousButton, attribute: .centerY, relatedBy: .equal, toItem: playPauseButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		
		constraintsArray.append(NSLayoutConstraint(item: progressLoader, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		constraintsArray.append(NSLayoutConstraint(item: progressLoader, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		constraintsArray.append(NSLayoutConstraint(item: progressLoader, attribute: .width, relatedBy: .equal, toItem: progressLoader, attribute: .height, multiplier: 1.0, constant: 0.0))
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[progressLoader(==60)]", options: [], metrics: nil, views: viewsDictionary))
		
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[previousButton(==playPauseButton)]-50-[playPauseButton(==66)]-50-[nextButton(==playPauseButton)]", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[playPauseButton(==78)]", options: [], metrics: nil, views: viewsDictionary))
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[nextButton(==66)]", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[previousButton(==nextButton)]", options: [], metrics: nil, views: viewsDictionary))
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[currentTimeLabel(==lengthLabel)]-10-[progressSlider]-10-[lengthLabel]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[progressSlider(==40)]-6-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[currentTimeLabel(==40)]-3-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[lengthLabel(==40)]-3-|", options: [], metrics: nil, views: viewsDictionary))
		
		NSLayoutConstraint.activate(constraintsArray)
	}
	
	//MARK: - Closure notifications -
	
	fileprivate func notifyOfDidPressNextButton() {
		didPressNextButtonClosures.forEach({ $0() })
	}
	
	fileprivate func notifyOfDidPressPreviousButton() {
		didPressPreviousButtonClosures.forEach({ $0() })
	}
	
	fileprivate func notifyOfInteracting(_ interacting: Bool) {
		interactingClosures.forEach({ $0(interacting) })
	}
	
	fileprivate func notifyOfNewVideo() {
		newVideoClosures.forEach({ $0() })
	}
	
	fileprivate func notifyOfStartedVideo() {
		startedVideoClosures.forEach({ $0() })
	}
	
}
