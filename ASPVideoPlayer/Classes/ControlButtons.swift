//
//  ControlButtons.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 12/12/2016.
//	Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/*
 Play and pause button.
 */
open class PlayPauseButton: UIButton {
    public enum ButtonState {
        case play
        case pause
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected == true {
                playPauseLayer.animationDirection = 0
            } else {
                playPauseLayer.animationDirection = 1
            }
        }
    }
    
    open override var tintColor: UIColor? {
        didSet {
            playPauseLayer.color = tintColor ?? .white
        }
    }
    
    open var buttonState: ButtonState = .play {
        didSet {
            switch buttonState {
            case .play:
                isSelected = true
            default:
                isSelected = false
            }
        }
    }
    
    private let playPauseLayer = PlayPauseLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        playPauseLayer.frame = bounds.insetBy(dx: (bounds.width / 4.0), dy: (bounds.height / 4.0))
        playPauseLayer.color = tintColor ?? .white
    }
    
    @objc fileprivate func changeState() {
        isSelected = !isSelected
    }
    
    private func commonInit() {
        playPauseLayer.frame = bounds.insetBy(dx: (bounds.width / 4.0), dy: (bounds.height / 4.0))
        playPauseLayer.color = tintColor ?? .white
        layer.addSublayer(playPauseLayer)
        
        addTarget(self, action: #selector(changeState), for: .touchUpInside)
    }
}
