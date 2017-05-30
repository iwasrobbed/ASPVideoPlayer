//
//  ASPVideoPlayer.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 09/12/2016.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/**
 A video player implementation with basic functionality.
 */
@available(iOS 10.0, *)
@IBDesignable open class ASPVideoPlayer: UIView {
    
    //MARK: - Read-Only Variables and Constants -
    
    open fileprivate(set) var videoPlayerView: ASPVideoPlayerView?
    
    //MARK: - Public Variables -
    
    /**
     Sets the controls to use for the player. By default the controls are ASPVideoPlayerControls.
     */
    open var videoPlayerControls: ASPBasicControls? {
        didSet {
            updateControls()
        }
    }
    
    /**
     Whether or not the controls should be hidden until the player is started / interacted with.
     */
    open var controlsInitiallyHidden = false {
        didSet {
            videoPlayerControls?.alpha = controlsInitiallyHidden ? 0 : 1
        }
    }
    
    /**
     The duration of the fade animation.
     */
    open var fadeDuration = 0.3
    
    /**
     A URL that the player will load. Can be a local or remote URL.
     */
    open var videoURL: URL? {
        didSet {
            guard let videoURL = videoURL else { return }
            videoPlayerView?.videoURL = videoURL
        }
    }
    
    /**
     Sets the color of the controls.
     */
    override open var tintColor: UIColor? {
        didSet {
            videoPlayerControls?.tintColor = tintColor
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
    
    //MARK: - Private methods -
    
    @objc internal func pauseOrPlayVideo() {
        if videoPlayerView?.status == .playing {
            videoPlayerView?.pauseVideo()
        } else {
            videoPlayerView?.playVideo()
        }
        toggleControls()
    }
    
    internal func toggleControls() {
        guard let controls = videoPlayerControls else { return }
        
        if controls.alpha > 0 && videoPlayerView?.status == .playing {
            hideControls()
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ASPVideoPlayer.hideControls), object: nil)
            showControls()
            
            if videoPlayerView?.status == .playing {
                perform(#selector(ASPVideoPlayer.hideControls), with: nil, afterDelay: 3.0)
            }
        }
    }
    
    internal func showControls() {
        UIView.animate(withDuration: fadeDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.videoPlayerControls?.alpha = 1.0
        }, completion: nil)
    }
    
    @objc internal func hideControls() {
        UIView.animate(withDuration: fadeDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.videoPlayerControls?.alpha = 0.0
        }, completion: nil)
    }
    
    private func updateControls() {
        videoPlayerControls?.tintColor = tintColor
        
        videoPlayerControls?.startedVideo = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.hideControls()
        }
        
        videoPlayerControls?.interacting = { [weak self] (isInteracting) in
            guard let strongSelf = self else { return }
            
            NSObject.cancelPreviousPerformRequests(withTarget: strongSelf, selector: #selector(ASPVideoPlayer.hideControls), object: nil)
            if isInteracting == true {
                strongSelf.showControls()
            } else {
                if strongSelf.videoPlayerView?.status == .playing {
                    strongSelf.perform(#selector(ASPVideoPlayer.hideControls), with: nil, afterDelay: 3.0)
                }
            }
        }
    }
    
    private func commonInit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ASPVideoPlayer.pauseOrPlayVideo))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        
        videoPlayerView = ASPVideoPlayerView()
        guard let videoPlayerView = videoPlayerView else { return }
        
        // Note: the controls closures will be set as part of the instantiation
        // so there's no need to explicitly call `updateControls`
        videoPlayerControls = ASPVideoPlayerControls(videoPlayer: videoPlayerView)
        guard let videoPlayerControls = videoPlayerControls else { return }
        
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerControls.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerControls.backgroundColor = UIColor.black.withAlphaComponent(0.15)

        addSubview(videoPlayerView)
        addSubview(videoPlayerControls)
        
        setupLayout()
    }
    
    private func setupLayout() {
        guard let videoPlayerView = videoPlayerView, let videoPlayerControls = videoPlayerControls else { return }
        let viewsDictionary: [String: Any] = ["videoPlayerView": videoPlayerView,
                                              "videoPlayerControls": videoPlayerControls]
        
        var constraintsArray = [NSLayoutConstraint]()
        
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))
        
        NSLayoutConstraint.activate(constraintsArray)
    }
}

@available(iOS 10.0, *)
extension ASPVideoPlayer: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let videoPlayerControls = videoPlayerControls else { return true }
        
        if let view = touch.view, view.isDescendant(of: self) == true, view != videoPlayerView, view != videoPlayerControls || touch.location(in: videoPlayerControls).y > videoPlayerControls.bounds.size.height - 50 {
            return false
        } else {
            return true
        }
    }
    
}
