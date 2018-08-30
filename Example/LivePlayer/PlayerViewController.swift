//
//  PlayerViewController.swift
//  GDNY
//
//  Created by st on 03/08/2018.
//  Copyright © 2018 st. All rights reserved.
//

import UIKit
import LivePlayer
import AVFoundation

@objc public protocol PlayerViewDelegate {

    @objc func didTapExitButton()
    @objc func didTapPlayButton(_ player: RegularPlayer)
}

class PlayerViewController: UIViewController, PlayerDelegate {

    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let player = RegularPlayer()

    public weak var delegate: PlayerViewDelegate?

    public var index: Int = 0

    public var videoURL: URL?

    public var isPreload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupPlayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.player.readyToPlay()
        self.player.player.playImmediately(atRate: 1.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isPreload == false {
            
            videoURL = nil
            loadVideo()
        }
        
        self.player.stop()
    }

    // MARK: Setup
    
    public func setup() {
        
        guard let _ = videoURL else {
            
            emptyPlayer()
            return
        }
    }

    public func setupPlayer() {

        player.delegate = self
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
    }
    
    public func loadVideo() {
        
        if let videoURL = videoURL {
            
            var isNeedUpdate = false
            if let asset = self.player.player.currentItem?.asset, let urlAsset = asset as? AVURLAsset {
                
                if videoURL.absoluteString != urlAsset.url.absoluteString {
                    
                    isNeedUpdate = true
                }
            } else {
                
                isNeedUpdate = true
            }
            
            if isNeedUpdate {
                
                self.player.set(AVURLAsset(url: videoURL))
            }

        }else{
            
            self.player.set(nil)
        }
    }

    func emptyPlayer() {
        
        videoURL = nil
        
        loadVideo()
    }

    // MARK: Actions

    @IBAction func didTapPlayButton() {

        delegate?.didTapPlayButton(self.player)

        self.player.playing ? self.player.stop() : self.player.start()
    }

    @IBAction func didTapExitButton() {

        delegate?.didTapExitButton()
    }

    private func getSeekTimeInterval() -> TimeInterval {

        return Double(self.slider.value) * self.player.duration
    }

    @IBAction func didChangeSliderValue() {
        self.player.seek(to: getSeekTimeInterval())
    }

    @IBAction func didFinishSliderValue() {
        self.player.forceSeek(to: getSeekTimeInterval())
    }

    // MARK: VideoPlayerDelegate

    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        NSLog("playerDidUpdateState \(player.state)")
        self.activityIndicator.isHidden = true

        switch player.state {
        case .loading:

            self.activityIndicator.isHidden = false

        case .failed:

            //nslog("🚫 \(String(describing: player.error))")
            break
            
        default:
            break
        }
    }

    func playerDidUpdatePlaying(player: Player) {
        self.playButton.isSelected = player.playing
    }

    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }

        let ratio = player.time / player.duration

        if self.slider.isHighlighted == false {
            self.slider.value = Float(ratio)
        }
    }

    func playerDidUpdateBufferedTime(player: Player) {

        guard player.duration > 0 else { return }

        let ratio = Int((player.bufferedTime / player.duration) * 100)

        self.label.text = "Buffer: \(ratio)%"
    }
}

open class CustomSlider: UISlider {
    
    @IBInspectable open var trackWidth: CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let multiValue: Float = value - 0.5
        let pixelAdjustment: Float = 35.0
        let xOriginDelta: Float = multiValue * ( Float(bounds.size.width) - pixelAdjustment)
        
        return CGRect(
            x: bounds.origin.x + CGFloat(xOriginDelta),
            y: bounds.origin.y,
            width: bounds.size.width,
            height: bounds.size.height
        )
    }
}

